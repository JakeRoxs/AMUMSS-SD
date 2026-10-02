import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


TOOL = Path(__file__).resolve().parents[1] / "scripts/hgpak_amumss.py"


class HGPakRoundTripTests(unittest.TestCase):
    def test_rejects_case_collisions(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            first = root / "Fixture.MBIN"
            second = root / "fixture.mbin"
            first.write_bytes(b"first")
            if second.exists():
                self.skipTest("Filesystem is not case-sensitive")
            second.write_bytes(b"second")
            archive = root / "collision.pak"
            result = subprocess.run(
                [sys.executable, str(TOOL), "--platform", "windows", "--pack",
                 "--output", str(archive), str(first), str(second)],
                cwd=root, capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("collide after lowercase normalization", result.stderr)
            self.assertFalse(archive.exists())

    def test_pc_round_trips(self):
        for compressed in (False, True):
            for mixed_case in (False, True):
                with self.subTest(compressed=compressed, mixed_case=mixed_case):
                    with tempfile.TemporaryDirectory() as temporary:
                        root = Path(temporary)
                        source = root / "input"
                        source.mkdir()
                        names = ["Fixture.MBIN", "METADATA/SubDir/Second.MBIN"] if mixed_case else [
                            "fixture.mbin", "metadata/subdir/second.mbin"]
                        payloads = [b"small fixture\x00\x01", os.urandom(150000)]
                        files = []
                        for name, data in zip(names, payloads):
                            path = source / name
                            path.parent.mkdir(parents=True, exist_ok=True)
                            path.write_bytes(data)
                            files.append(str(path))
                        archive = root / "fixture.pak"
                        command = [sys.executable, str(TOOL), "--platform", "windows",
                                   "--pack", "--output", str(archive)]
                        if compressed:
                            command.append("--compress")
                        result = subprocess.run(command + files, cwd=root,
                                                capture_output=True, text=True)
                        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                        output = root / "output"
                        result = subprocess.run(
                            [sys.executable, str(TOOL), "--platform", "windows",
                             "--unpack", "--output", str(output), str(archive)],
                            cwd=root, capture_output=True, text=True,
                        )
                        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                        extracted = list(output.rglob("*.mbin"))
                        self.assertEqual(len(extracted), 2, result.stdout + result.stderr)
                        for name, data in zip(names, payloads):
                            matches = [path for path in extracted if path.name == Path(name).name.lower()]
                            self.assertEqual(len(matches), 1)
                            self.assertEqual(matches[0].read_bytes(), data)
                        self.assertTrue((output / names[1].lower()).is_file())


if __name__ == "__main__":
    unittest.main()
