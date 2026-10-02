"""Extract explicit PC game files using the pinned upstream HGPAKTool API."""

import argparse
from pathlib import Path, PurePosixPath
import sys
import struct


ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = ROOT / "third_party/hgpaktool"
if not (UPSTREAM / "hgpaktool/api.py").is_file():
    raise RuntimeError("Missing HGPAKTool submodule; run git submodule update --init --recursive")
sys.path.insert(0, str(UPSTREAM))
from hgpaktool.api import HGPAKFile, HGPakHeader, InvalidFileException


def extract_files(archive, filenames, destination, upper=False, overwrite=False):
    """Return written paths; missing files and unsafe/occupied outputs are errors."""
    names = []
    for filename in filenames:
        name = filename.replace("\\", "/").lower()
        path = PurePosixPath(name)
        if (not name or path.is_absolute() or ":" in name
                or any(part in ("", ".", "..") for part in name.split("/"))):
            raise ValueError(f"Unsafe game-relative path: {filename}")
        names.append(name)
    if not names or len(set(names)) != len(names):
        raise ValueError("Request must contain unique, nonempty normalized paths")

    # The optimized upstream path assumes compressed offsets. Avoid it for
    # uncompressed archives, where ordinary extraction uses absolute offsets.
    header = HGPakHeader()
    with Path(archive).open("rb") as source:
        header.read(source)
    if not header.is_compressed:
        with HGPAKFile(str(archive), platform="windows") as pak:
            data = dict(pak.extract(names))
    else:
        data = HGPAKFile(str(archive), platform="windows").extract_specific(names, as_buffer=False)
    missing = set(names) - data.keys()
    if missing:
        raise FileNotFoundError(f"Files absent or unreadable in archive: {sorted(missing)}")

    destination = Path(destination)
    targets = []
    for name in names:
        relative = "GLOBALS/" + name if "/" not in name else name
        if upper:
            relative = relative.upper()
        target = destination / relative
        if target.is_symlink() or any(parent.is_symlink() for parent in target.parents):
            raise ValueError(f"Refusing symlink output path: {target}")
        if target.exists() and not overwrite:
            raise FileExistsError(f"Refusing to overwrite: {target}")
        targets.append(target)
    for name, target in zip(names, targets):
        target.parent.mkdir(parents=True, exist_ok=True)
        mode = "wb" if overwrite else "xb"
        with target.open(mode) as output:
            output.write(data[name])
    return targets


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("files", nargs="+", help="Exact game-relative paths, not globs")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--upper", action="store_true", help="AMUMSS uppercase output convention")
    args = parser.parse_args()
    try:
        targets = extract_files(args.archive, args.files, args.output, args.upper)
    except (OSError, ValueError, AssertionError, struct.error, InvalidFileException) as error:
        parser.exit(1, f"Extraction failed: {error}\n")
    print(f"Extracted {len(targets)} files to {args.output}")


if __name__ == "__main__":
    main()
