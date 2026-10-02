import configparser
import json
from pathlib import Path
import re
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


class DependencyOwnershipTests(unittest.TestCase):
    def test_application_provenance_is_not_a_runtime_dependency(self):
        dependencies = json.loads((ROOT / "dependencies.json").read_text())
        origin = json.loads((ROOT / "upstream-release.json").read_text())
        self.assertNotIn("amumss_baseline", dependencies)
        self.assertNotIn("arrayinfo", dependencies["remaining_tools"])
        self.assertEqual(origin["application_origin"]["version"], "5.6.2.0w")
        self.assertIn("no automatic source reset", origin["application_origin"]["update_policy"])
        self.assertIn("arrayinfo", origin["application_components"])

    def test_submodule_paths_urls_and_checked_out_commits_match_manifest(self):
        dependencies = json.loads((ROOT / "dependencies.json").read_text())
        modules = configparser.ConfigParser()
        modules.read(ROOT / ".gitmodules")
        paths = {section["path"]: section["url"] for section in modules.values() if "path" in section}
        self.assertEqual(set(paths), {item["path"] for item in dependencies["submodules"].values()})
        for dependency in dependencies["submodules"].values():
            with self.subTest(path=dependency["path"]):
                self.assertTrue(paths[dependency["path"]].startswith("https://github.com/"))
                self.assertIsNotNone(re.fullmatch(r"[0-9a-f]{40}", dependency["commit"]))
                revision = subprocess.check_output(
                    ["git", "-C", str(ROOT / dependency["path"]), "rev-parse", "HEAD"], text=True
                ).strip()
                self.assertEqual(revision, dependency["commit"])

    def test_downloads_are_https_and_checksum_pinned(self):
        dependencies = json.loads((ROOT / "dependencies.json").read_text())
        for name in ("lua", "mbincompiler"):
            with self.subTest(name=name):
                self.assertTrue(dependencies[name]["url"].startswith("https://"))
                self.assertIsNotNone(re.fullmatch(r"[0-9a-f]{64}", dependencies[name]["sha256"]))


if __name__ == "__main__":
    unittest.main()
