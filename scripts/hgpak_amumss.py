"""AMUMSS-owned compatibility interface backed by the pinned HGPAKTool submodule."""

import argparse
import fnmatch
import json
from pathlib import Path
import shutil
import struct
import tempfile

from extract_game_files import HGPAKFile, InvalidFileException, extract_files


def game_path(name, upper=False):
    name = name.replace("\\", "/")
    if "/" not in name:
        name = "GLOBALS/" + name
    return name.upper() if upper else name


def read_plan(path, root=None):
    plan = json.loads(Path(path).read_text())
    if not isinstance(plan, dict) or not plan:
        raise ValueError("Extraction plan must be a nonempty archive-to-files object")
    result = []
    for archive, names in plan.items():
        if not isinstance(archive, str) or not isinstance(names, list) or not names:
            raise ValueError("Plan entries require an archive path and nonempty file list")
        if not all(isinstance(name, str) for name in names):
            raise ValueError("Plan filenames must be strings")
        archive_path = Path(archive)
        if not archive_path.is_absolute():
            if root is None:
                raise ValueError("Relative archive paths require a root directory")
            if ".." in archive_path.parts:
                raise ValueError("Archive path must stay inside the supplied root")
            archive_path = Path(root) / archive_path
            if not archive_path.resolve().is_relative_to(Path(root).resolve()):
                raise ValueError("Archive path escapes the supplied root")
        if archive_path.suffix.lower() != ".pak":
            raise ValueError("Plan entries must reference .pak archives")
        result.append((archive_path, names))
    return result


def pack_files(files, output, compress=False):
    output = Path(output)
    if output.exists() or output.is_symlink():
        raise FileExistsError(f"Refusing to overwrite: {output}")
    root = Path(files[0]).resolve().parent
    entries = {}
    for item in map(Path, files):
        candidates = sorted(item.rglob("*")) if item.is_dir() else [item]
        for source in candidates:
            if not source.is_file():
                continue
            relative = source.resolve().relative_to(root).as_posix().lower()
            if relative in entries:
                raise ValueError("Archive paths collide after lowercase normalization")
            entries[relative] = source
    if not entries:
        raise ValueError("No files to pack")
    with tempfile.TemporaryDirectory(prefix="amumss-pack-") as temporary:
        stage = Path(temporary)
        for relative, source in entries.items():
            target = stage / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
        manifest = stage / "fixture.pak.manifest"
        if manifest.exists():
            raise ValueError("Input uses the reserved archive-manifest filename")
        manifest.write_bytes(("\r\n".join(entries) + "\r\n").encode())
        packed = stage / "output.pak"
        HGPAKFile.repack(manifest, packed, compress=compress, platform="windows")
        if output.is_symlink() or any(parent.is_symlink() for parent in output.parents):
            raise ValueError("Refusing symlink output path")
        with output.open("xb") as target, packed.open("rb") as source:
            shutil.copyfileobj(source, target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("filenames", nargs="+")
    parser.add_argument("--platform", choices=["windows", "linux"], default="windows")
    parser.add_argument("-U", "--unpack", action="store_true")
    parser.add_argument("-P", "--pack", action="store_true")
    parser.add_argument("-L", "--list", action="store_true")
    parser.add_argument("-p", "--plain", action="store_true")
    parser.add_argument("--hash", type=Path)
    parser.add_argument("-O", "--output", type=Path)
    parser.add_argument("-f", "--filter", action="append")
    parser.add_argument("-j", "--json", type=Path)
    parser.add_argument("--upper", action="store_true")
    parser.add_argument("--compress", "-c", action="store_true")
    parser.add_argument("-A", "--amumssverbose", action="store_true", help="Suppress extraction summary")
    parser.add_argument("--nmspeverbose", action="store_true")
    args = parser.parse_args()
    try:
        if args.pack:
            if args.list or args.hash or args.json or args.unpack:
                raise ValueError("Packing cannot be combined with read operations")
            pack_files(args.filenames, args.output or "hgpak.pak", args.compress)
            return
        plan = args.json
        if not plan and len(args.filenames) == 1 and args.filenames[0].lower().endswith(".json"):
            plan = Path(args.filenames[0])
        if plan:
            if args.list or args.hash:
                raise ValueError("JSON extraction plans cannot be combined with listing/hashing")
            root = args.filenames[0] if len(args.filenames) == 1 and Path(args.filenames[0]).is_dir() else None
            requests = read_plan(plan, root)
        else:
            archives = []
            for item in map(Path, args.filenames):
                archives.extend(sorted(item.glob("*.pak")) if item.is_dir() else [item])
            requests = []
            for archive in archives:
                with HGPAKFile(archive, platform="windows") as pak:
                    names = [name for name in pak.files if not args.filter or any(
                        fnmatch.fnmatchcase(candidate, pattern.replace("\\", "/").lower())
                        for candidate in (name.lower(), game_path(name).lower())
                        for pattern in args.filter)]
                if names:
                    requests.append((archive, names))
        if not requests:
            raise FileNotFoundError("No matching game files in the supplied archives")
        listings = {}
        hashes = {}
        count = 0
        for archive, names in requests:
            if args.nmspeverbose:
                print(f"Unpacking ==> {archive.name}")
            if args.list:
                listings[str(archive.resolve())] = names
            elif args.hash:
                with HGPAKFile(archive, platform="windows") as pak:
                    for name, digest in pak.get_hashes(names):
                        hashes[game_path(name, upper=True)] = digest.upper()
            else:
                count += len(extract_files(archive, names, args.output or "EXTRACTED", args.upper, overwrite=True))
        if args.list:
            if args.plain:
                with (args.output or Path("PAK_FILE_CONTENT.txt")).open("a") as output:
                    for archive, names in listings.items():
                        output.write(f"\nListing {Path(archive).name}\n")
                        for name in names:
                            prefix = "GLOBALS/" if Path(archive).name == "NMSARC.globals.pak" else ""
                            output.write(prefix + name.upper() + "\n")
            else:
                (args.output or Path("filenames.json")).write_text(json.dumps(listings, indent=2) + "\n")
        elif args.hash:
            args.hash.parent.mkdir(parents=True, exist_ok=True)
            with args.hash.open("x") as output:
                json.dump(hashes, output, indent=2)
                output.write("\n")
        elif not args.amumssverbose:
            print(f"Unpacked {count} files from {len(requests)} archives")
    except (OSError, ValueError, AssertionError, struct.error, InvalidFileException) as error:
        parser.exit(1, f"HGPAKTool adapter failed: {error}\n")


if __name__ == "__main__":
    main()
