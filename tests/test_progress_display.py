import importlib.util
import os
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/amumss-progress.py"
spec = importlib.util.spec_from_file_location("amumss_progress_ui", SCRIPT)
ui = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = ui
spec.loader.exec_module(ui)
GTK_TESTS_AVAILABLE = importlib.util.find_spec("gi") is not None and shutil.which("xvfb-run") is not None


class ProgressDisplayTests(unittest.TestCase):
    def test_milestones_are_monotonic_and_escape_script_names(self):
        progress = ui.Progress()
        progress.consume("Starting to process script #1/2 ['<first&mod>.lua']")
        self.assertIn("&lt;first&amp;mod&gt;.lua", progress.text())
        progress.consume("Scripts processed: 1")
        previous = progress.percent
        progress.consume("Starting to process script #2/2 ['second.lua']")
        self.assertGreaterEqual(progress.percent, previous)
        progress.consume("Compiling MXML file(s) in MOD folder")
        self.assertEqual(progress.stage, "Compiling modified files")
        self.assertEqual(progress.percent, 94)
        progress.consume("Copying files to TOOLS")
        self.assertEqual(progress.percent, 97)

    def test_example_messages_do_not_inflate_warning_counts(self):
        progress = ui.Progress()
        progress.consume("Example [WARNING] message")
        progress.consume("Example [ERROR] message")
        progress.consume("\x1b[31m>>> [WARNING] real warning\x1b[0m")
        progress.consume("Error: build failed")
        self.assertEqual((progress.warnings, progress.errors), (1, 1))

    def test_unrecognized_script_count_never_reports_completion(self):
        progress = ui.Progress()
        progress.consume("Scripts processed: 999")
        self.assertLess(progress.percent, 100)

    def run_frontend(self, status, close_window=False):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            processor = root / "processor.sh"
            processor.write_text(
                '#!/bin/bash\n'
                'exec > >(tee "$AMUMSS_RUN_DIR/console.log") 2>&1\n'
                'echo "=== Running AMUMSS Processor ==="\n'
                'echo "Starting to process script #1/1 [\x27mod.lua\x27]"\n'
                'for i in {1..1000}; do echo "verbose detail $i"; done\n'
                'echo "Compiling MXML files"\n'
                'exit "$FIXTURE_STATUS"\n'
            )
            env = dict(os.environ, AMUMSS_RUN_DIR=str(root), FIXTURE_STATUS=str(status),
                       GDK_BACKEND="x11", GSK_RENDERER="cairo")
            command = [sys.executable, str(SCRIPT), str(processor)]
            if close_window:
                code = (
                    'import importlib.util, sys, gi; gi.require_version("Gtk", "4.0"); '
                    'from gi.repository import GLib, Gtk; '
                    's=importlib.util.spec_from_file_location("ui", sys.argv[1]); '
                    'm=importlib.util.module_from_spec(s); sys.modules["ui"]=m; s.loader.exec_module(m); '
                    'GLib.timeout_add(100, lambda: [w.close() for w in Gtk.Window.list_toplevels()] and False); '
                    'sys.exit(m.run(sys.argv[2], []))'
                )
                command = [sys.executable, "-c", code, str(SCRIPT), str(processor)]
            result = subprocess.run(["xvfb-run", "-a", *command],
                                    env=env, text=True, capture_output=True, timeout=15)
            log = (root / "console.log").read_text()
            return result, log

    @unittest.skipUnless(GTK_TESTS_AVAILABLE, "GTK GUI lifecycle tests require system PyGObject and Xvfb")
    def test_success_is_quiet_but_retains_full_log(self):
        result, log = self.run_frontend(0)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("verbose detail", result.stdout)
        self.assertIn("verbose detail 1000", log)

    @unittest.skipUnless(GTK_TESTS_AVAILABLE, "GTK GUI lifecycle tests require system PyGObject and Xvfb")
    def test_failed_build_preserves_status(self):
        result, log = self.run_frontend(2)
        self.assertEqual(result.returncode, 2)
        self.assertIn("verbose detail 1000", log)

    @unittest.skipUnless(GTK_TESTS_AVAILABLE, "GTK GUI lifecycle tests require system PyGObject and Xvfb")
    def test_closing_progress_window_does_not_discard_build(self):
        result, log = self.run_frontend(0, close_window=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("verbose detail 1000", log)


if __name__ == "__main__":
    unittest.main()
