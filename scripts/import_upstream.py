"""Import pinned upstream source without running it or replacing local edits."""

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def selected(name, config):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or "\\" in name or ":" in name:
        raise ValueError(f"Unsafe archive path: {name}")
    if any(part in config["excluded_directories"] for part in path.parts[:-1]):
        return False
    if name in config["excluded_files"]:
        return False
    if any(name.startswith(prefix) for prefix in config.get("excluded_prefixes", [])):
        return False
    return (name in config["included_files"]
            or path.suffix.lower() in config["included_extensions"])


def digest(path):
    with path.open("rb") as stream:
        value = hashlib.sha256()
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(chunk)
        return value.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path, help="Downloaded pinned .7z release")
    parser.add_argument("--check", action="store_true",
                        help="Compare imported files to upstream without writing")
    args = parser.parse_args()
    config = json.loads((ROOT / "upstream-release.json").read_text())
    archive = args.archive.resolve()
    if (archive.stat().st_size != config["size_bytes"]
            or digest(archive) != config["sha256"]):
        parser.error("Archive does not match the pinned size and SHA-256")
    seven_zip = shutil.which("7z") or shutil.which("7zz")
    if not seven_zip:
        parser.error("7-Zip is required (7z or 7zz on PATH)")

    listing = subprocess.run(
        [seven_zip, "l", "-slt", "-ba", str(archive)],
        check=True, capture_output=True, text=True,
    ).stdout
    names = []
    for record in listing.split("\n\n"):
        fields = dict(line.split(" = ", 1) for line in record.splitlines()
                      if " = " in line)
        name = fields.get("Path")
        if name and fields.get("Folder") != "+" and selected(name, config):
            names.append(name)
    if not names:
        parser.error("No source files found in archive listing")

    destination = ROOT / config["destination"]
    with tempfile.TemporaryDirectory(prefix="amumss-import-") as temporary:
        stage = Path(temporary) / "source"
        file_list = Path(temporary) / "files.txt"
        file_list.write_text("\n".join(names) + "\n", encoding="utf-8")
        subprocess.run(
            [seven_zip, "x", "-y", "-spd", "-scsUTF-8", str(archive),
             f"-o{stage}", f"@{file_list}"], check=True, capture_output=True,
        )
        missing = []
        for name in names:
            source = stage / name
            target = destination / name
            if not source.is_file() or source.is_symlink():
                parser.error(f"Expected regular source file: {name}")
            if target.is_symlink() or any(p.is_symlink() for p in target.parents):
                parser.error(f"Refusing symlink destination: {target}")
            if target.exists():
                if not target.is_file() or digest(target) != digest(source):
                    parser.error(f"Local file differs; refusing to overwrite: {target}")
            else:
                missing.append(name)
        if args.check:
            if missing:
                parser.error(f"Missing {len(missing)} imported files: {missing[0]}")
        else:
            # All existing destinations were checked before copying any files.
            for name in missing:
                target = destination / name
                target.parent.mkdir(parents=True, exist_ok=True)
                with target.open("xb") as output, (stage / name).open("rb") as source:
                    shutil.copyfileobj(source, output)
        print(f"Verified {len(names)} upstream files; "
              f"{'check only' if args.check else f'imported {len(missing)} new files'}.")


if __name__ == "__main__":
    main()
