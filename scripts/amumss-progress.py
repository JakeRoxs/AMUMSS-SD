#!/usr/bin/env python3
"""Show build milestones with a compact live view of the saved debug stream."""
from dataclasses import dataclass
import codecs
import html
import os
import re
import subprocess
import sys


ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")


@dataclass
class Progress:
    percent: int = 0
    stage: str = "Preparing selected mods"
    script: str = ""
    current: int = 0
    total: int = 0
    warnings: int = 0
    errors: int = 0

    def consume(self, line):
        line = ANSI.sub("", line).strip()
        if "Example" in line:
            return
        if "[WARNING]" in line:
            self.warnings += 1
        if "[ERROR]" in line or line.startswith(("Error:", "ERROR:")):
            self.errors += 1
        match = re.search(r"Starting to process script.*?#(\d+)/(\d+) \['(.*?)'\]", line)
        if match:
            self.current, self.total = int(match[1]), int(match[2])
            self.script = match[3]
            self.stage = "Applying mod changes"
            self.percent = max(self.percent, int(5 + 85 * (self.current - 1) / max(self.total, 1)))
        elif "Running AMUMSS Processor" in line:
            self.stage = "Checking selected scripts"
            self.percent = max(self.percent, 5)
        elif "Extracting files" in line:
            self.stage = "Extracting required game files"
        elif "decompiling" in line.lower():
            self.stage = "Preparing editable game data"
        elif "Success loading USER script" in line:
            self.stage = "Applying mod changes"
        elif "Looking for >>>" in line or "Looking to >>>" in line:
            self.stage = "Applying mod changes"
        elif "Compiling MXML" in line:
            self.stage = "Compiling modified files"
            if self.current == self.total and self.total:
                self.percent = max(self.percent, 94)
        elif "Creating backup file" in line or "Copying files to TOOLS" in line or "Saving final files" in line:
            self.stage = "Saving build output"
            if self.current == self.total and self.total:
                self.percent = max(self.percent, 97)
        elif match := re.search(r"Scripts processed:\s*(\d+)", line):
            self.percent = max(self.percent, int(5 + 85 * int(match[1]) / max(self.total, 1)))
        self.percent = min(self.percent, 99)

    def text(self):
        detail = f"Mod {self.current} of {self.total}: {self.script}" if self.script else "Getting the workspace ready"
        return (f"<b>{html.escape(self.stage)}</b>&#10;{html.escape(detail)}&#10;"
                f"<small>Warnings: {self.warnings}   Errors: {self.errors}&#10;"
                "Stage-based progress. Full details saved in run history.&#10;"
                "Closing this window hides progress; the build continues.</small>")


def run(processor, mods):
    import gi
    gi.require_version("Gtk", "4.0")
    from gi.repository import Gio, GLib, Gtk

    progress = Progress()
    application = Gtk.Application(application_id="org.amumss.ModBuilder",
                                  flags=Gio.ApplicationFlags.NON_UNIQUE)
    status = 127

    def activate(app):
        nonlocal status
        window = Gtk.ApplicationWindow(application=app, title="AMUMSS Mod Builder")
        window.set_default_size(720, 460)
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        for edge in ("top", "bottom", "start", "end"):
            getattr(content, f"set_margin_{edge}")(16)
        summary = Gtk.Label(xalign=0, wrap=True)
        summary.set_markup(progress.text())
        content.append(summary)
        bar = Gtk.ProgressBar()
        content.append(bar)
        heading = Gtk.Box(spacing=12)
        title = Gtk.Label(label="Live debug log (last 400 lines)", xalign=0, hexpand=True)
        heading.append(title)
        follow = Gtk.CheckButton(label="Follow output", active=True)
        heading.append(follow)
        content.append(heading)
        log_view = Gtk.TextView(editable=False, cursor_visible=False, monospace=True)
        log_view.set_left_margin(8)
        log_view.set_right_margin(8)
        log_view.set_top_margin(8)
        log_view.set_bottom_margin(8)
        scroll = Gtk.ScrolledWindow(vexpand=True)
        scroll.set_min_content_height(200)
        scroll.set_child(log_view)
        frame = Gtk.Frame()
        frame.set_child(scroll)
        content.append(frame)
        window.set_child(content)

        def hide_window(widget):
            widget.set_visible(False)
            return True

        window.connect("close-request", hide_window)
        window.present()
        app.hold()
        try:
            build = subprocess.Popen(["bash", processor, *mods], stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT)
        except OSError as error:
            print(f"Unable to start processor: {error}", file=sys.stderr)
            app.release()
            app.quit()
            return

        os.set_blocking(build.stdout.fileno(), False)
        decoder = codecs.getincrementaldecoder("utf-8")("replace")
        pending = ""
        eof = False
        buffer = log_view.get_buffer()
        end_mark = buffer.create_mark(None, buffer.get_end_iter(), False)

        def read_output():
            nonlocal pending, eof, status
            lines = []
            if not eof:
                try:
                    data = os.read(build.stdout.fileno(), 65536)
                except BlockingIOError:
                    data = None
                if data is not None:
                    pending += decoder.decode(data, final=not data)
                    parts = pending.split("\n")
                    lines, pending = parts[:-1], parts[-1]
                    if not data:
                        eof = True
                        if pending:
                            lines.append(pending)
                        pending = ""
            if lines:
                for line in lines:
                    progress.consume(line)
                # Rendering is batched; the on-disk console log remains unbounded.
                text = "\n".join(ANSI.sub("", line).rstrip("\r") for line in lines) + "\n"
                buffer.insert(buffer.get_end_iter(), text)
                excess = buffer.get_line_count() - 400
                if excess > 0:
                    _, boundary = buffer.get_iter_at_line(excess)
                    buffer.delete(buffer.get_start_iter(), boundary)
                summary.set_markup(progress.text())
                bar.set_fraction(progress.percent / 100)
                if follow.get_active():
                    log_view.scroll_to_mark(end_mark, 0, True, 0, 1)
            result = build.poll()
            if eof and result is not None:
                build.stdout.close()
                status = result if result >= 0 else 128 - result
                window.destroy()
                app.release()
                app.quit()
                return GLib.SOURCE_REMOVE
            return GLib.SOURCE_CONTINUE

        GLib.timeout_add(75, read_output)

    application.connect("activate", activate)
    application.run([sys.argv[0]])
    return status


if __name__ == "__main__":
    try:
        sys.exit(run(sys.argv[1], sys.argv[2:]))
    except (OSError, ImportError) as error:
        print(f"Unable to start the build display: {error}", file=sys.stderr)
        sys.exit(127)
