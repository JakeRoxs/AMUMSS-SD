"""Build pinned Linux Lua dependencies in a fresh user-owned directory."""

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request


ROOT = Path(__file__).resolve().parents[1]


def verify_sources(config, root=ROOT):
    for name, dependency in config["submodules"].items():
        path = root / dependency["path"]
        if not (path / ".git").exists():
            raise ValueError(f"Missing {name}; run git submodule update --init --recursive")
        revision = subprocess.check_output(
            ["git", "-C", str(path), "rev-parse", "HEAD"], text=True
        ).strip()
        if revision != dependency["commit"]:
            raise ValueError(f"{name} is at {revision}, expected {dependency['commit']}")
        if subprocess.check_output(["git", "-C", str(path), "status", "--porcelain"], text=True):
            raise ValueError(f"{name} has local changes; refusing to build unpinned source")


def unpack_lua(archive, destination, version):
    prefix = f"lua-{version}"
    with tarfile.open(archive, "r:gz") as bundle:
        for member in bundle.getmembers():
            path = PurePosixPath(member.name)
            if (path.is_absolute() or ".." in path.parts or not path.parts
                    or path.parts[0] != prefix or not (member.isfile() or member.isdir())):
                raise ValueError(f"Unsafe Lua archive member: {member.name}")
        # Only regular files/directories below the expected prefix are allowed;
        # destination is a private fresh staging directory without existing links.
        bundle.extractall(destination)
    return destination / prefix / "src"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="New or empty runtime directory")
    parser.add_argument("--jobs", type=int, default=2)
    args = parser.parse_args()
    if sys.platform != "linux":
        parser.error("This bootstrap currently supports Linux only")
    if args.jobs < 1:
        parser.error("--jobs must be positive")
    config = json.loads((ROOT / "dependencies.json").read_text())
    for tool in ("make", "cc", "c++", "git"):
        if not shutil.which(tool):
            parser.error(f"Required build tool missing: {tool}")
    try:
        verify_sources(config)
    except (ValueError, subprocess.CalledProcessError) as error:
        parser.error(str(error))
    requested = args.destination.absolute()
    if requested.is_symlink():
        parser.error("Runtime destination itself must not be a symlink")
    # Bazzite's /home points into /var/home; canonicalize existing parents so
    # normal $HOME destinations work without weakening output-link checks.
    destination = requested.resolve()
    if not destination.parent.is_dir():
        parser.error("Destination parent must already exist")
    if destination.exists() and (not destination.is_dir() or any(destination.iterdir())):
        parser.error("Destination must be new or empty; existing runtimes are not overwritten")

    with tempfile.TemporaryDirectory(prefix="amumss-runtime-", dir=destination.parent) as temporary:
        stage = Path(temporary)
        archive = stage / "lua.tar.gz"
        with urllib.request.urlopen(config["lua"]["url"], timeout=60) as response, archive.open("xb") as output:
            shutil.copyfileobj(response, output)
        if hashlib.sha256(archive.read_bytes()).hexdigest() != config["lua"]["sha256"]:
            parser.error("Lua archive checksum mismatch")
        lua_source = unpack_lua(archive, stage, config["lua"]["version"])
        subprocess.run(["make", "-C", str(lua_source), "linux-noreadline", f"-j{args.jobs}"], check=True)
        modules = stage / "modules"
        modules.mkdir()
        sources = config["submodules"]
        subprocess.run([
            "cc", "-O2", "-fPIC", "-shared", f"-I{lua_source}",
            str(ROOT / sources["luafilesystem"]["path"] / "src/lfs.c"),
            "-o", str(modules / "lfs.so"),
        ], check=True)
        lanes_source = ROOT / sources["lanes"]["path"] / "src"
        subprocess.run([
            "c++", "-std=c++20", "-O2", "-fPIC", "-shared", "-pthread",
            "-include", "unistd.h", f"-I{lua_source}",
            *map(str, sorted(lanes_source.glob("*.cpp"))), "-o", str(modules / "lanes_core.so"),
        ], check=True)
        lua_modules = stage / "lua"
        lua_modules.mkdir()
        shutil.copy2(lanes_source / "lanes.lua", lua_modules / "lanes.lua")
        shutil.copy2(ROOT / sources["lua-bint"]["path"] / "bint.lua", lua_modules / "bint.lua")
        binary = stage / "bin"
        binary.mkdir()
        for name in ("lua", "luac"):
            shutil.copy2(lua_source / name, binary / name)
        licenses = stage / "licenses"
        licenses.mkdir()
        for name, filename in (("lanes", "COPYRIGHT"), ("luafilesystem", "LICENSE"),
                               ("lua-bint", "LICENSE")):
            shutil.copy2(ROOT / sources[name]["path"] / filename, licenses / f"{name}.txt")
        # Verify actual upstream wrapper and integer module before publishing.
        probe = (
            "package.path=arg[1]..'/lua/?.lua;'..package.path; "
            "package.cpath=arg[1]..'/modules/?.so;'..package.cpath; "
            "assert(require('lfs').currentdir()); local b=require('bint')(512); "
            "assert(tostring(b(21)+b(21))=='42'); "
            "local l=require('lanes').configure(); "
            "local w=l.gen('*',function(x) return x*2 end)(21); assert(w[1]==42); "
            "print('Native runtime probe passed',_VERSION)"
        )
        # -e receives following arguments as Lua script parameters; '-' reads an
        # empty stdin script rather than trying to execute the staging directory.
        subprocess.run([str(binary / "lua"), "-e", probe, "-", str(stage)], input="", text=True, check=True)
        (stage / "dependencies.json").write_text(json.dumps(config, indent=2) + "\n")
        if destination.exists():
            destination.rmdir()
        shutil.move(str(stage), str(destination))
    print(f"Runtime built at {destination}")
    print(f"LUA_PATH={destination}/lua/?.lua;;")
    print(f"LUA_CPATH={destination}/modules/?.so;;")


if __name__ == "__main__":
    main()
