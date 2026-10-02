"""Verify native builder output against the extracted originals, without deployment."""
import hashlib
from pathlib import Path
import sys
import xml.etree.ElementTree as ET


builder = Path(sys.argv[1])
output = Path(sys.argv[2])
generated = list((builder / "MOD").rglob("*.MXML"))
assert generated, "No generated MXML files"
missing = [str(path) for path in generated if not path.with_suffix(".MBIN").is_file()]
assert not missing, f"Missing compiled counterparts: {missing[:10]}"
for path in generated:
    ET.parse(path)
packed = list(output.rglob("*.MBIN"))
assert len(packed) == len(generated), (len(packed), len(generated))
assert not list(output.rglob("*.MXML")), "MXML leaked into game output"
changed = []
for original in (builder / "_TEMP/EXTRACTED").rglob("*.MBIN"):
    relative = original.relative_to(builder / "_TEMP/EXTRACTED")
    result = output / relative
    assert result.is_file(), f"Missing output for {relative}"
    if hashlib.sha256(original.read_bytes()).digest() != hashlib.sha256(result.read_bytes()).digest():
        changed.append(str(relative))
assert "GLOBALS/GCDEBUGOPTIONS.GLOBAL.MBIN" in changed, "Globals modification missing"
assert "METADATA/REALITY/TABLES/BASEBUILDINGOBJECTSTABLE.MBIN" in changed, "Building table unchanged"
print(f"Valid XML files with compiled counterparts: {len(generated)}")
print(f"Output MBIN files: {len(packed)}; no MXML or extra MOD nesting")
print(f"Changed original MBIN files: {len(changed)}")
for path in changed:
    print(f"  {path}")
