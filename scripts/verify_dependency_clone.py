"""Verify fresh recursive dependency initialization without committing application changes."""

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

from setup_native_runtime import ROOT, verify_sources


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--parent", type=Path, required=True, help="Existing temporary workspace parent")
    args = parser.parse_args()
    if not args.parent.is_dir():
        parser.error("Temporary workspace parent must exist")
    config = json.loads((ROOT / "dependencies.json").read_text())
    with tempfile.TemporaryDirectory(prefix="amumss-dependency-clone-", dir=args.parent) as temporary:
        root = Path(temporary)
        subprocess.run(["git", "init", "--quiet", str(root)], check=True)
        shutil.copy2(ROOT / ".gitmodules", root / ".gitmodules")
        subprocess.run(["git", "-C", str(root), "add", ".gitmodules"], check=True)
        for dependency in config["submodules"].values():
            subprocess.run([
                "git", "-C", str(root), "update-index", "--add", "--cacheinfo",
                f"160000,{dependency['commit']},{dependency['path']}",
            ], check=True)
        subprocess.run(["git", "-C", str(root), "submodule", "update", "--init", "--recursive"], check=True)
        verify_sources(config, root)
    print("Fresh recursive dependency initialization passed; no application commit was created.")


if __name__ == "__main__":
    main()
