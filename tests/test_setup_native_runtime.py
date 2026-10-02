import importlib.util
import io
from pathlib import Path
import tarfile
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("setup_native_runtime", ROOT / "scripts/setup_native_runtime.py")
BOOTSTRAP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BOOTSTRAP)


class RuntimeBootstrapTests(unittest.TestCase):
    def test_missing_submodule_has_actionable_error(self):
        with tempfile.TemporaryDirectory() as temporary:
            with self.assertRaisesRegex(ValueError, "submodule update --init"):
                BOOTSTRAP.verify_sources({"submodules": {"test": {"path": "missing", "commit": "unused"}}},
                                         Path(temporary))

    def test_rejects_unsafe_archive_members(self):
        for name, kind in (("../escape", tarfile.REGTYPE), ("/absolute", tarfile.REGTYPE),
                           ("other/file", tarfile.REGTYPE), ("lua-5.4.9/link", tarfile.SYMTYPE)):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                archive = root / "lua.tar.gz"
                with tarfile.open(archive, "w:gz") as bundle:
                    member = tarfile.TarInfo(name)
                    member.type = kind
                    member.size = 1 if kind == tarfile.REGTYPE else 0
                    member.linkname = "../escape" if kind == tarfile.SYMTYPE else ""
                    bundle.addfile(member, io.BytesIO(b"x") if member.size else None)
                with self.assertRaises(ValueError):
                    BOOTSTRAP.unpack_lua(archive, root, "5.4.9")
                self.assertFalse((root / "lua-5.4.9").exists())

    def test_rejects_wrong_revision_and_dirty_source(self):
        expected = "a" * 40
        for responses, message in ((["b" * 40 + "\n"], "expected"),
                                   ([expected + "\n", " M source.c\n"], "local changes")):
            with self.subTest(message=message), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                (root / "dependency/.git").mkdir(parents=True)
                config = {"submodules": {"test": {"path": "dependency", "commit": expected}}}
                with patch.object(BOOTSTRAP.subprocess, "check_output", side_effect=responses):
                    with self.assertRaisesRegex(ValueError, message):
                        BOOTSTRAP.verify_sources(config, root)


if __name__ == "__main__":
    unittest.main()
