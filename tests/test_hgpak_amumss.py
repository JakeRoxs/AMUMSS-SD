import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


TOOL = Path(__file__).resolve().parents[1] / "scripts/hgpak_amumss.py"


class AMUMSSArchiveInterfaceTests(unittest.TestCase):
    def test_plan_listing_and_hash_contracts(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "sample.mbin"
            source.write_bytes(b"representative payload")
            archive = root / "NMSARC.globals.pak"
            def run(*arguments):
                return subprocess.run([sys.executable, str(TOOL), *map(str, arguments)],
                                      cwd=root, capture_output=True, text=True)
            result = run("--pack", "--compress", "-O", archive, source)
            self.assertEqual(result.returncode, 0, result.stderr)
            plan = root / "plan.json"
            plan.write_text(json.dumps({str(archive): ["SAMPLE.MBIN"]}))
            output = root / "EXTRACTED"
            result = run("-U", "--upper", "-A", "-O", output, plan)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "")
            self.assertEqual((output / "GLOBALS/SAMPLE.MBIN").read_bytes(), source.read_bytes())
            listing = root / "PAK_FILE_CONTENT.txt"
            result = run("-L", "-p", "--upper", "-O", listing, archive)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(listing.read_text(), "\nListing NMSARC.globals.pak\nGLOBALS/SAMPLE.MBIN\n")
            hashes = root / "hash.json"
            result = run("--hash", hashes, archive)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(hashes.read_text()), {
                "GLOBALS/SAMPLE.MBIN": hashlib.md5(source.read_bytes()).hexdigest().upper()})
            relative = root / "relative.json"
            relative.write_text(json.dumps({archive.name: ["sample.mbin"]}))
            result = run("--json", relative, "-O", root / "relative-output", root)
            self.assertEqual(result.returncode, 0, result.stderr)
            result = run("-U", "-O", root / "missing", "-f", "does-not-exist", archive)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse((root / "missing").exists())
            result = run("-U", "-O", root / "globals-filter", "-f", "GLOBALS/SAMPLE.MBIN", archive)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((root / "globals-filter/GLOBALS/sample.mbin").read_bytes(), source.read_bytes())

    def test_rejects_invalid_plans(self):
        for plan in ({}, [], {"x.pak": "not a list"}, {"../x.pak": ["sample.mbin"]}):
            with self.subTest(plan=plan), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                source = root / "plan.json"
                source.write_text(json.dumps(plan))
                result = subprocess.run(
                    [sys.executable, str(TOOL), "--json", str(source), str(root),
                     "-O", str(root / "output")], cwd=root, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((root / "output").exists())


if __name__ == "__main__":
    unittest.main()
