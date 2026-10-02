import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "import_upstream", ROOT / "scripts/import_upstream.py"
)
IMPORTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(IMPORTER)


class SourceImportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = json.loads((ROOT / "upstream-release.json").read_text())

    def test_preserves_sources_assets_and_licenses(self):
        for name in (
            "BUILDMOD.bat", "MODBUILDER/LIST_ModScriptMBINs.BAT",
            "MODBUILDER/LoadHelpers.lua",
            "MODBUILDER/ArrayInfo/ToBuild/Program.cs",
            "MODBUILDER/LICENSES/LANES-COPYRIGHT",
            "MODBUILDER/buildmod_auto.backup",
            "MODBUILDER/css styles/AMUMSS.gif",
            "MODBUILDER/ArrayInfo/ArrayInfo.runtimeconfig.json",
        ):
            with self.subTest(name=name):
                self.assertTrue(IMPORTER.selected(name, self.config))

    def test_excludes_generated_data_even_when_named_like_source(self):
        for name in (
            "TOOLS/NMSPE_Output/Diff/example.lua",
            "MODBUILDER/ArrayInfo/ToBuild/obj/AssemblyInfo.cs",
            "MODBUILDER/ArrayInfo/ToBuild/Build/Release/output.txt",
            "MODBUILDER/ArrayInfo/ToBuild/.vs/layout.txt",
            "MODBUILDER/MBINCompilerDownloader/temp1.txt",
            "MODBUILDER/NMS_FOLDER_BAK.txt",
        ):
            with self.subTest(name=name):
                self.assertFalse(IMPORTER.selected(name, self.config))

    def test_excludes_binaries(self):
        for name in ("tool.exe", "tool.dll", "tool.lib", "tool.exe.AV", "tool.lnk"):
            with self.subTest(name=name):
                self.assertFalse(IMPORTER.selected(name, self.config))

    def test_does_not_restore_replaced_dependency_sources(self):
        for name in ("MODBUILDER/bint.lua", "MODBUILDER/lanes.lua",
                     "MODBUILDER/HGPAK/HGPAKTool/hgpaktool.py",
                     "MODBUILDER/HGPAK/HGPAKTool/utils.py"):
            with self.subTest(name=name):
                self.assertFalse(IMPORTER.selected(name, self.config))

    def test_rejects_unsafe_paths(self):
        for name in ("../file.lua", "/file.lua", "a/../../file.lua",
                     "C:/file.lua", "a\\file.lua"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                IMPORTER.selected(name, self.config)

    def test_digest_matches_known_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "fixture"
            path.write_bytes(b"source baseline\r\n")
            self.assertEqual(IMPORTER.digest(path),
                             hashlib.sha256(b"source baseline\r\n").hexdigest())


if __name__ == "__main__":
    unittest.main()
