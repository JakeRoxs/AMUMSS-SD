import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("extract_game_files", ROOT / "scripts/extract_game_files.py")
ADAPTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ADAPTER)
PACKER = ROOT / "scripts/hgpak_amumss.py"


class ExtractionTests(unittest.TestCase):
    def test_explicit_extraction_matches_both_archive_formats(self):
        for compressed in (False, True):
            with self.subTest(compressed=compressed), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                fixture = root / "sample.mbin"
                fixture.write_bytes(b"fixture" * 20000)
                archive = root / "test.pak"
                command = [sys.executable, str(PACKER), "--platform", "windows", "--pack",
                           "--output", str(archive)]
                if compressed:
                    command.append("--compress")
                subprocess.run(command + [str(fixture)], check=True, capture_output=True, cwd=root)
                targets = ADAPTER.extract_files(archive, ["SAMPLE.MBIN"], root / "output", upper=True)
                self.assertEqual(targets, [root / "output/GLOBALS/SAMPLE.MBIN"])
                self.assertEqual(targets[0].read_bytes(), fixture.read_bytes())
                with self.assertRaises(FileExistsError):
                    ADAPTER.extract_files(archive, ["sample.mbin"], root / "output", upper=True)
                with self.assertRaises(FileNotFoundError):
                    ADAPTER.extract_files(archive, ["missing.mbin"], root / "absent")
                self.assertFalse((root / "absent").exists())

    def test_rejects_unsafe_and_duplicate_requests_before_archive_access(self):
        for names in (["../escape"], ["/absolute"], ["C:\\escape"], ["a/./b"],
                      ["a//b"], [], ["SAMPLE.MBIN", "sample.mbin"]):
            with self.subTest(names=names), self.assertRaises(ValueError):
                ADAPTER.extract_files("nonexistent.pak", names, "unused")

    def test_malformed_archive_fails_without_output(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "invalid.pak"
            archive.write_bytes(b"not an HGPAK archive")
            output = root / "output"
            result = subprocess.run(
                [sys.executable, str(ROOT / "scripts/extract_game_files.py"),
                 str(archive), "sample.mbin", "--output", str(output)],
                capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Extraction failed", result.stderr)
            self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
