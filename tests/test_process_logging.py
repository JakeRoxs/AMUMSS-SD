import os
import shlex
import shutil
from pathlib import Path
import subprocess
import tempfile
import unittest
import zipfile


PROCESSOR = Path(__file__).resolve().parents[1] / "scripts/amumss-process.sh"


class ProcessLoggingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.builder = self.root / "AMUMSS/MODBUILDER"
        self.builder.mkdir(parents=True)
        old_scripts = self.builder.parent / "ModScript"
        old_scripts.mkdir()
        (old_scripts / "test_mod.lua").write_text("-- unrelated old fixture\n")
        self.runtime = self.root / "runtime"
        (self.runtime / "bin").mkdir(parents=True)
        lua = self.runtime / "bin/lua"
        lua.write_text(
            '#!/bin/bash\n'
            'echo "fixture stdout"\n'
            'echo "[WARNING] fixture stderr" >&2\n'
            'find ../ModScript -maxdepth 1 -type f -name "*.lua" -printf "Built: %f\\n"\n'
            'if [[ -d ../ModScript/ModHelperScripts ]]; then find ../ModScript/ModHelperScripts -type f -printf "Helper: %f\\n"; fi\n'
            'echo "fixture report" > ../REPORT.lua\n'
            'echo "fixture compiler log" > MBINCompiler.log\n'
            'mkdir -p ../CreatedMODS\n'
            'if [[ ${FIXTURE_NO_OUTPUT:-N} != Y ]]; then mkdir -p ../CreatedMODS/fixture_mod; echo "fixture binary" > ../CreatedMODS/fixture_mod/test.MBIN; fi\n'
            'if [[ ${FIXTURE_FAILED_LIST:-N} == Y ]]; then echo "script aborted" > FailedScriptList.txt; fi\n'
            'exit "${FIXTURE_STATUS:-0}"\n'
        )
        lua.chmod(0o755)
        self.logs = self.root / "logs"
        self.build_temp = self.root / "build-temp"
        self.build_temp.mkdir()
        self.env = dict(os.environ, AMUMSS_DIR=str(self.builder),
                        LUA_RUNTIME=str(self.runtime), NMS_PATH=str(self.root),
                        AMUMSS_LOG_ROOT=str(self.logs), TMPDIR=str(self.build_temp))
        self.env.pop("AMUMSS_RUN_DIR", None)

    def run_processor(self, *inputs):
        result = subprocess.run(
            ["bash", str(PROCESSOR), *map(str, inputs)], env=self.env,
            capture_output=True, text=True, timeout=15,
        )
        self.assertEqual(list(self.build_temp.iterdir()), [], "Temporary build data was not cleaned up")
        return result

    def make_zip(self, name, files):
        archive = self.root / name
        with zipfile.ZipFile(archive, "w") as out:
            for path, content in files.items():
                out.writestr(path, content)
        return archive

    def test_success_and_failure_keep_separate_logs_and_reports(self):
        mods = self.root / "input mods"
        mods.mkdir()
        (mods / "++selected.lua").write_text("-- fixture\n")
        for status in (0, 7):
            self.env["FIXTURE_STATUS"] = str(status)
            result = self.run_processor(mods)
            self.assertEqual(result.returncode, status, result.stderr)
        runs = sorted(self.logs.iterdir())
        self.assertEqual(len(runs), 2)
        statuses = set()
        for run in runs:
            info = (run / "Logs/run-info.txt").read_text()
            statuses.add(info.split("Exit status: ")[-1].strip())
            console = (run / "Logs/console.log").read_text()
            self.assertIn("fixture stdout", console)
            self.assertIn("[WARNING] fixture stderr", console)
            self.assertTrue((run / "Logs/AMUMSS-REPORT.lua").is_file())
            self.assertTrue((run / "Logs/MODBUILDER-MBINCompiler.log").is_file())
            self.assertIn("++selected.lua", (run / "Logs/scripts.sha256").read_text())
            self.assertNotIn("test_mod.lua", (run / "Logs/scripts.sha256").read_text())
            if "Exit status: 0" in info:
                self.assertEqual({path.name for path in run.iterdir()}, {"Output", "Logs"})
                self.assertEqual((run / "Output/fixture_mod/test.MBIN").read_text(), "fixture binary\n")
            else:
                self.assertEqual({path.name for path in run.iterdir()}, {"Logs"})
        self.assertEqual(statuses, {"0", "7"})

    def test_all_prefixes_and_nested_scripts_are_imported(self):
        archive = self.make_zip("multi mod (test).ZIP", {
            "~~~~BuildFrame_SACS.lua": "-- script\n",
            "folder/deeper/another/FF_FancyDiscoveryMessage_703.lua": "-- script\n",
            "research/FF_ResearchTreesRescaled_600.LUA": "-- script\n",
        })
        result = self.run_processor(archive)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for name in ("~~~~BuildFrame_SACS.lua", "FF_FancyDiscoveryMessage_703.lua", "FF_ResearchTreesRescaled_600.lua"):
            self.assertIn(f"Built: {name}", result.stdout)
        self.assertNotIn("Built: test_mod.lua", result.stdout)
        self.assertTrue((self.builder.parent / "ModScript/test_mod.lua").is_file())
        self.assertFalse((self.builder.parent / "REPORT.lua").exists())

    def test_missing_script_cancels_entire_selection(self):
        valid = self.make_zip("valid.zip", {"good.lua": "-- script\n"})
        invalid = self.make_zip("no-script.zip", {"file.MBIN": "data"})
        result = self.run_processor(valid, invalid)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("build cancelled", result.stdout)
        self.assertNotIn("fixture stdout", result.stdout)

    def test_duplicate_names_are_not_overwritten(self):
        first = self.make_zip("one.zip", {"mod.lua": "-- first\n"})
        second = self.make_zip("two.zip", {"mod.lua": "-- second\n"})
        result = self.run_processor(first, second)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Duplicate script filename", result.stdout)
        self.assertNotIn("fixture stdout", result.stdout)

    def test_corrupt_archive_does_not_start_processor(self):
        archive = self.root / "broken.zip"
        archive.write_bytes(b"not a zip archive")
        result = self.run_processor(archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("fixture stdout", result.stdout)

    def test_zero_exit_with_failed_script_list_is_incomplete(self):
        mod = self.root / "standalone.lua"
        mod.write_text("-- script\n")
        self.env["FIXTURE_FAILED_LIST"] = "Y"
        result = self.run_processor(mod)
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        run = next(self.logs.iterdir())
        self.assertIn("script aborted", (run / "Logs/MODBUILDER-FailedScriptList.txt").read_text())
        self.assertFalse((run / "Output").exists())

    def test_nonzero_processor_still_reports_failed_script_guidance(self):
        mod = self.root / "standalone.lua"
        mod.write_text("-- script\n")
        self.env.update(FIXTURE_FAILED_LIST="Y", FIXTURE_STATUS="2")
        result = self.run_processor(mod)
        self.assertEqual(result.returncode, 2)
        self.assertIn("see FailedScriptList.txt in run history", result.stdout)

    def test_auxiliary_helpers_are_preserved_but_not_selected_as_mods(self):
        shared = self.builder.parent / "ModScript/ModHelperScripts"
        shared.mkdir()
        (shared / "Shared.lua").write_text("-- shared helper\n")
        archive = self.make_zip("with helpers.zip", {
            "mod.lua": "-- mod\n",
            "ModHelperScripts/Library.lua": "-- archive helper\n",
        })
        result = self.run_processor(archive)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        run = next(self.logs.iterdir())
        self.assertIn("Helper: Shared.lua", result.stdout)
        self.assertIn("Helper: Library.lua", result.stdout)
        self.assertIn("Selected scripts: 1", (run / "Logs/run-info.txt").read_text())
        self.assertNotIn("Built: Library.lua", result.stdout)
        self.assertNotIn("Built: Shared.lua", result.stdout)

    def test_conflicting_selected_helpers_cancel_build(self):
        first = self.make_zip("one.zip", {
            "one.lua": "-- mod\n", "ModHelperScripts/Library.lua": "-- one\n",
        })
        second = self.make_zip("two.zip", {
            "two.lua": "-- mod\n", "ModHelperScripts/Library.lua": "-- two\n",
        })
        result = self.run_processor(first, second)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Conflicting helper", result.stdout)
        self.assertNotIn("fixture stdout", result.stdout)

    def test_empty_success_is_not_published_as_final_output(self):
        mod = self.root / "standalone.lua"
        mod.write_text("-- script\n")
        self.env["FIXTURE_NO_OUTPUT"] = "Y"
        result = self.run_processor(mod)
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        self.assertIn("produced no final files", result.stdout)
        self.assertEqual({path.name for path in next(self.logs.iterdir()).iterdir()}, {"Logs"})

    def test_failed_export_leaves_no_partial_output_or_staging(self):
        mod = self.root / "standalone.lua"
        mod.write_text("-- script\n")
        tools = self.root / "tools"
        tools.mkdir()
        rsync = tools / "rsync"
        rsync.write_text(
            '#!/bin/bash\n'
            'for arg in "$@"; do\n'
            '  if [[ "$arg" == */CreatedMODS/ ]]; then\n'
            '    echo "partial" > "${@: -1}/partial.MBIN"\n'
            '    exit 23\n'
            '  fi\n'
            'done\n'
            f'exec {shlex.quote(shutil.which("rsync"))} "$@"\n'
        )
        rsync.chmod(0o755)
        self.env["PATH"] = f"{tools}:{os.environ['PATH']}"
        result = self.run_processor(mod)
        self.assertEqual(result.returncode, 23)
        self.assertEqual({path.name for path in next(self.logs.iterdir()).iterdir()}, {"Logs"})

    def test_existing_run_is_not_overwritten(self):
        mod = self.root / "standalone.lua"
        mod.write_text("-- script\n")
        self.assertEqual(self.run_processor(mod).returncode, 0)
        run = next(self.logs.iterdir())
        original_info = (run / "Logs/run-info.txt").read_bytes()
        original_console = (run / "Logs/console.log").read_bytes()
        self.env["AMUMSS_RUN_DIR"] = str(run)
        result = self.run_processor(mod)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((run / "Logs/run-info.txt").read_bytes(), original_info)
        self.assertEqual((run / "Logs/console.log").read_bytes(), original_console)


if __name__ == "__main__":
    unittest.main()
