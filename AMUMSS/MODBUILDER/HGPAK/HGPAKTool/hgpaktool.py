"""Compatibility source entry point; implementation is owned by upstream."""

from pathlib import Path
import runpy
import sys


scripts = Path(__file__).resolve().parents[3] / "scripts"
sys.path.insert(0, str(scripts))
if __name__ == "__main__":
    runpy.run_path(str(scripts / "hgpak_amumss.py"), run_name="__main__")
