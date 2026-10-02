"""Compare isolated legacy and upstream extraction processes without changing game files."""

import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("filenames", nargs="+", help="Exact filenames stored in the archive")
    parser.add_argument("--legacy", type=Path, required=True)
    parser.add_argument("--adapter", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True, help="New benchmark workspace")
    parser.add_argument("--repeats", type=int, default=7)
    args = parser.parse_args()
    if args.repeats < 2:
        parser.error("Use at least two measured repeats")
    if args.output.exists() or args.output.is_symlink():
        parser.error("Benchmark workspace must not exist")
    if not args.output.parent.is_dir():
        parser.error("Benchmark workspace parent must exist")
    args.output.mkdir()
    commands = {
        "legacy": [sys.executable, str(args.legacy), "--platform", "windows", "-U",
                   *[value for filename in args.filenames for value in ("-f", filename.lower())]],
        "upstream": [sys.executable, str(args.adapter), str(args.archive), *args.filenames],
    }
    reference = None
    results = {name: [] for name in commands}
    first = {}
    # Alternate process order; never drop kernel caches or alter host settings.
    for iteration in range(args.repeats + 1):
        order = list(commands) if iteration % 2 == 0 else list(reversed(commands))
        for name in order:
            output = args.output / f"{name}-{iteration}"
            metrics = args.output / f"{name}-{iteration}.metrics"
            command = commands[name] + ["--output", str(output)]
            if name == "legacy":
                command.append(str(args.archive))
            started = time.perf_counter()
            result = subprocess.run(["/usr/bin/time", "-f", "%M", "-o", str(metrics), *command],
                                    capture_output=True, text=True, cwd=args.output)
            if result.returncode:
                raise RuntimeError(f"{name} failed: {result.stdout}\n{result.stderr}")
            seconds = time.perf_counter() - started
            files = list(output.rglob("*"))
            files = [path for path in files if path.is_file()]
            if len(files) != len(args.filenames):
                raise RuntimeError(f"{name} extracted {len(files)} files, expected {len(args.filenames)}")
            digest = {path.relative_to(output).as_posix().lower(): hashlib.sha256(path.read_bytes()).hexdigest()
                      for path in files}
            if reference is not None and digest != reference:
                raise RuntimeError(f"{name} extraction differs from baseline")
            reference = digest
            sample = {"seconds": seconds, "peak_rss_kib": int(metrics.read_text().strip()),
                      "output_bytes": sum(path.stat().st_size for path in files)}
            if iteration == 0:
                first[name] = sample
            else:
                results[name].append(sample)
    report = {
        "archive": str(args.archive), "filenames": args.filenames,
        "cache_note": "Uncontrolled first observation followed by warm-cache repeats; no cold-cache claim",
        "includes_process_startup": True, "sha256": reference, "first_observation": first,
        "temporary_payload_bytes": sum(sample["output_bytes"] for sample in first.values())
                                   + sum(sample["output_bytes"] for samples in results.values() for sample in samples),
        "samples": results,
        "summary": {name: {
            "median_seconds": statistics.median(sample["seconds"] for sample in samples),
            "median_peak_rss_kib": statistics.median(sample["peak_rss_kib"] for sample in samples),
        } for name, samples in results.items()},
    }
    text = json.dumps(report, indent=2)
    (args.output / "results.json").write_text(text + "\n")
    print(text)


if __name__ == "__main__":
    main()
