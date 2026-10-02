# AMUMSS-SD

A source-first development fork of AMUMSS for investigating and implementing
Steam Deck support, primarily on **Bazzite Deck (`bazzite-deck`)**, with **SteamOS**
as an additional intended target. AMUMSS processes Lua scripts into No Man's Sky
mods; it is not a mod manager.

## Platform Targets

- **Primary development and testing target:** Steam Deck hardware running Bazzite
  Deck, which is the maintainer's actual device environment.
- **Additional intended target:** Steam Deck hardware running SteamOS.

The goal is a shared Linux workflow with user-local dependencies, avoiding
distribution-specific system modifications. Installation, runtime availability,
Steam library discovery, and Desktop/Gaming Mode behavior must still be validated
on each distribution. Passing tests on Bazzite Deck does not by itself establish
SteamOS compatibility; neither platform is currently verified as supported.

## Current Status

The editable application source is present under `AMUMSS/`, initially imported
byte-for-byte from upstream **v5.6.2.0W**, with third-party implementations now
maintained through pinned submodules and tested PC-facing adapters. Upstream describes this release as a full installation for NMS >= 5.5;
compatibility with any particular current game build still requires validation.

**This checkout is not yet a runnable Steam Deck application.** Windows batch
orchestration, bundled-runtime assumptions, and automatic update behavior remain
unchanged. Do not run the upstream launcher in your development checkout: its
self-updater can replace source files. Use a separate disposable runtime directory
for future execution tests, never your only copy of user scripts or game data.

## Repository Layout

- `AMUMSS/BUILDMOD.bat`: upstream Windows entry point.
- `AMUMSS/MODBUILDER/`: build orchestration, Lua processor, helpers, and licenses.
- `AMUMSS/MODBUILDER/HGPAK/HGPAKTool/`: thin compatibility Python entry point.
- `AMUMSS/MODBUILDER/ArrayInfo/ToBuild/`: bundled C# helper source and project.
- `AMUMSS/CONFIG/`, `AMUMSS/README/`, `AMUMSS/TOOLS/`: default configuration,
  upstream documentation, utilities, and learning examples.
- `upstream-release.json`: AMUMSS origin/provenance, recovery archive and import selection policy.
- `scripts/import_upstream.py`: reproducible source importer; never runs imported code.
- `third_party/`: pinned upstream HGPAKTool, Lanes, LuaFileSystem and lua-bint submodules.
- `dependencies.json`: external source revisions, runtime/tool pins and remaining external-tool audit.
- `scripts/extract_game_files.py`: native exact-file extraction pilot using upstream HGPAKTool.
- `tests/`: importer tests and synthetic HGPAKTool round-trip regression tests.
- `docs/todos/`: Steam Deck investigation and implementation work items.

The pre-existing tracked update PAKs and `AMUMSS/TOOL/NMSPE_Output/` data are retained
unchanged. They are historical artifacts, not the source of the imported application.
The upstream release uses `TOOLS/` (plural); the old `TOOL/` tree is separate.

## Upstream Dependencies

Initialize pinned sources after cloning:

```sh
git submodule update --init --recursive
```

Do not use `git submodule update --remote` for normal setup: the recorded commits
are the reviewed dependency baseline. HGPAKTool is pinned to release 1.1.3; Lanes
to 4.0.0; LuaFileSystem to 1.9.0; lua-bint to an exact upstream commit. Lua and
MBINCompiler use checksum-pinned release archives/binaries instead of unofficial
source mirrors. Copied HGPAKTool, bint and Lanes implementations have been replaced
with thin entry points to pinned source. Native processor integration and Windows
executable dispatch remain in progress.

AMUMSS is our editable application, not a dependency. Its origin information and
project-owned ArrayInfo helper audit live in `upstream-release.json`; release
archives/import tooling are for provenance and recovery, not routine synchronization.
Normal development modifies `AMUMSS/` directly. Future upstream application changes
are reviewed selective merges that preserve this fork, not automatic replacements.

Fresh recursive dependency initialization can be checked without committing local
application changes or altering this checkout:

```sh
python3 scripts/verify_dependency_clone.py --parent /path/to/existing-temp-parent
```

The check creates a disposable Git index with the recorded gitlinks, initializes
all submodules recursively, verifies their exact clean revisions, and removes the
temporary workspace. This validates dependency initialization; a published full
application clone still needs verification once the fork's changes are committed.

The experimental Linux bootstrap builds Lua 5.4.9 and its native modules into a
new user-owned directory, checking submodule revisions and the Lua download hash:

```sh
python3 scripts/setup_native_runtime.py /path/to/new-runtime
```

The destination's parent must exist, and the destination must be new or empty.
Required tools are Python, Git, make, a C compiler (`cc`) and a C++20 compiler
(`c++`). It does not install system packages or change global PATH. It prints the
process-local `LUA_PATH` and `LUA_CPATH` needed to use the runtime, retains dependency
licenses, and tests integer arithmetic and a Lanes worker before publishing output.
The bootstrap has built Lua 5.4.9/LuaFileSystem 1.9.0 and upstream Lanes on the
Bazzite Deck. Integer arithmetic, a threaded worker and guarded AMUMSS helper
initialization pass. Helper paths/processes still need Linux adaptation; these
probes do not establish a functional full mod build.

`LoadHelpers.lua` now loads LuaFileSystem when the global is absent, so standard
native Lua does not need the bundled interpreter's preload behavior. A guarded
integration probe exercises AMUMSS large-seed conversion, file reads and threaded
module loading without running builds or downloaded mods:

```sh
LUA_PATH='/path/to/repo/AMUMSS/MODBUILDER/?.lua;;' \
LUA_CPATH='/path/to/runtime/modules/?.so;;' \
  /path/to/runtime/bin/lua tests/probe_amumss_helpers.lua \
  /path/to/repo/AMUMSS/MODBUILDER /path/to/repo/dependencies.json
```

The probe blocks subprocesses/file writes and skips startup removals. It does not
validate cleanup or native filesystem/process portability. Application source
now intentionally differs from the historical archive; import `--check` reports
that difference instead of treating it as an automatic update opportunity.

The new extraction pilot uses upstream's optimized explicit-file API for compressed
PC archives and ordinary extraction for uncompressed archives. It rejects missing
files, unsafe requests and occupied output paths, and puts root-level files under
`GLOBALS` consistently. Example with a user-owned virtual environment containing
`requirements-runtime.txt` dependencies:

```sh
python3 scripts/extract_game_files.py /path/to/NMSARC.globals.pak \
  gcdebugoptions.global.mbin --upper --output /path/to/new-test-directory
```

`scripts/hgpak_amumss.py` provides PC extraction filters, AMUMSS JSON extraction
plans, plain/JSON listings, valid JSON content hashes, and experimental packing via
upstream's manifest API. JSON plans map absolute archive paths to lists of files,
or relative archive paths with `--json plan.json /path/to/archive-root`. Core flags
include `-U`, `-L`, `-p`, `-O`, `-f`, `--upper`, `-A`, and `--hash`.

Only the tested PC-facing interface is provided here; optional historical switches,
Switch/macOS archive modes and full Windows executable integration are not claimed
as compatible. Use upstream's separate CLI for other supported archive modes.
Copied compressor/utility modules are removed, and the historical source importer
excludes migrated dependency paths. Original local fixes are preserved in
`patches/legacy-hgpaktool-fixes.patch` (applies with `git apply -p2` inside a pristine
extracted legacy release). Submodules remain unmodified.

The adapter extracted the installed game's globals fixture byte-identically to the
bundled tool. Seven alternating warm-cache repeats on Bazzite Deck measured median
process time of 0.207 seconds upstream versus 0.194 seconds bundled, with median
peak RSS of 28,460 versus 29,332 KiB. This tiny-fixture result includes process
startup and shows no speedup; larger/batched extraction remains to be measured.
An eight-file globals workload (53,756 bytes total) likewise measured 0.208 seconds
upstream versus 0.194 seconds bundled, with byte-identical output and median peak
RSS of 28,468 versus 29,184 KiB. These tests favor maintainability/correctness as
the demonstrated benefit, not a performance claim; large metadata archives and
long-lived API use remain separate future measurements.
`scripts/benchmark_extraction.py` retains per-run timings, memory and byte checks
in a new user-owned workspace. No system cache flushing or game writes are needed.

As of 2026-10-01, 5.6.2.0w is the newest verified public AMUMSS full release and
its next-update URL returns 404. A downloaded mod's 5.8.2.2w marker is unresolved;
this fork does not claim that its AMUMSS baseline is fully current.

External tool ownership is recorded in `dependencies.json`: legacy PSARC support
is not replaced by HGPAKTool, Selene diagnostics require compatibility testing,
and Windows shell/console utilities still require native orchestration. The
project-owned ArrayInfo helper is recorded with application provenance; its source
declares Linux support but references an unavailable `libMBIN..dll`. These
unresolved integrations prevent claiming full feature parity, but the unverified
newer AMUMSS marker does not block development of this application fork.

## Reproduce the Source Import

The source files belong in Git, so a normal clone does not need an import step.
To reproduce or verify the baseline, install Python 3.9+ and 7-Zip (`7z` or `7zz`),
download the [pinned release archive](https://github.com/HolterPhylo/AMUMSS/releases/download/v5.6.2.0W/UPDATE.-.5.6.2.0.FULL.7z),
then run from the repository root:

```sh
python3 scripts/import_upstream.py /path/to/UPDATE.-.5.6.2.0.FULL.7z
python3 scripts/import_upstream.py /path/to/UPDATE.-.5.6.2.0.FULL.7z --check
```

Run regression tests in an isolated Python environment:

```sh
python3 -m venv /tmp/amumss-sd-tests
/tmp/amumss-sd-tests/bin/python -m pip install -r requirements-test.txt
/tmp/amumss-sd-tests/bin/python -m unittest discover -s tests -v
```

Native MBINCompiler startup, a single game-data conversion round trip, and
compressed/uncompressed HGPAKTool round trips have passed on the Bazzite Deck.
This does not establish full AMUMSS script execution or in-game mod loading.

The importer verifies archive size and SHA-256, stages selected files, and refuses
to overwrite differing local files. Identical files are left alone. `--check`
compares the source baseline without writing; it will intentionally fail after
local source modifications. The recorded hash pins the inspected download, not
an independently verified upstream signature. No automatic downloads are performed.

The import excludes executables, DLLs, static libraries, IDE caches, compiled
outputs, historical compilers, generated NMS inventories, and known runtime state.
Windows binaries and .NET runtimes are therefore **not supplied by a source clone**.
For future runtime testing, extract the complete pinned archive into a separate
directory and review its update behavior before executing anything. Linux tooling
and a safe runtime/bootstrap workflow are still pending; do not install Windows
runtime packages system-wide on Bazzite Deck or SteamOS based on the historical
instructions below.

## Licensing

The original root `LICENSE` and the release's
`AMUMSS/MODBUILDER/LICENSES/AMUMSS_LICENSE.txt` are preserved. AMUMSS is MIT-licensed;
bundled components retain their own notices under `MODBUILDER/LICENSES/` and in
their source. Importing available source does not establish redistribution rights
or source availability for every auxiliary executable in the full release.

## Historical Upstream README

The following is retained for upstream context. It describes the Windows
distribution, not installation or support guarantees for this fork.

A tool to mod No Man's Sky (NMS) using lua scripts

AMUMSS is NOT a mod manager, nor can it be used as such. It is a script processor.

In other words: a tool that uses .lua scripts to create mod files

> > > .lua scripts go into the ModScript folder (created after you run BULDMOD.bat)

> > > NMS < v5.5, .pak files go into NMS PCBANKS\MODS (a folder you create to use mods with NMS)

> > > NMS >= v5.5, mod are sub-folders in NMS GAMEDATA\MODS folder

> QUESTIONS

        * Questions are better asked in NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:
                    [https://discord.gg/HFjnmnwe67](https://discord.gg/HFjnmnwe67)
        We have channel #amumss-lua dedicated to AMUMSS/NMSPE with helpful modders and Wbertro#8596 (aka TheBossBoy)

> FOR HELP WITH INSTALLATION:
> Refer to [https://www.nexusmods.com/nomanssky/mods/2626](https://www.nexusmods.com/nomanssky/mods/2626)

IMPORTANT NOTES:
AMUMSS is always up-to-date (except with a MAJOR update like NMS > v5.5) but it needs MBINCompiler.exe to be updated
(it is done automatically when available)

Current MBINCompiler.exe versions REQUIRE '.NET 8 x64 Desktop Runtime' latest version to run:
It can be found at https://dotnet.microsoft.com/download/dotnet/8.0/runtime  
 (.NET 6/7/9/10... are NOT backward compatible with .NET 8)

STARTING July 17th, 2023: NEWER MBINCompiler.exe versions REQUIRE '.NET 6 x64 Desktop Runtime' latest version to run:
It can be found at https://dotnet.microsoft.com/download/dotnet/6.0/runtime  
 (.NET 7/8/... are NOT backward compatible with .NET 6)

OLDER MBINCompiler.exe versions still REQUIRE '.NET 5 x64 Desktop Runtime' latest version to run:
It can be found at https://dotnet.microsoft.com/download/dotnet/5.0/runtime  
 (.NET 6/7/8/... are NOT backward compatible with .NET 5)

For now, this is a repository of AMUMSS versions going forward.

SEE the [RELEASES](https://github.com/HolterPhylo/AMUMSS/releases) for latest version for NMS >= v5.5
or previous release for NMS < v5.5

> These version will auto-update with the execution of BUILDMOD.bat.
> It may take one or many re-start of BUILDMOD.bat to bring it to the latest version.
> No worry, it is fast (only depends on your internet speed)

DOWNLOAD and INSTALLATION:
\*\*\* Follow installation instructions found in file at [https://www.nexusmods.com/nomanssky/mods/2626](https://www.nexusmods.com/nomanssky/mods/2626)

> DOWNLOAD COMPLETE VERSION

    * COMPLETE VERSION available as a .7z release at:
        https://github.com/HolterPhylo/AMUMSS/releases (you need the 'Latest' release: AMUMSS.7z, +/- 145MB)
    * 'Unblock' the downloaded file in 'Properties' in the windows explorer
    * you can unzip it with 7zip at: https://www.7-zip.org/download.html

Unzipping in a folder like C:\AMUMSS is recommended

    * IMPORTANT Note:
    	+ Your anti-virus may detect some component of AMUMSS and block/quarantine it.
    	  Be assure it is not a virus but its behavior may be interpreted as such by some anti-virus.
    	+ Please make sure to create an 'exception' in your anti-virus BEFORE executing anything in AMUMSS main folder.
    	+ Also a reboot may be required as some anti-virus do not correctly register the exception when it is created.

> INSTALLATION

    * Complete the step in the DOWNLOAD COMPLETE VERSION section above before continuing
      *** FOLLOW the instructions at https://www.nexusmods.com/nomanssky/mods/2626 ***

    * No accented characters in the path of AMUMSS folder
    * Always de-compress/un-zip in a new folder on any drive like X:\AMUMSS (OR in the previous folder)
      xxxxx NEVER in any system folder (Note: the Desktop, Downloads, Documents are system folders) xxxxx

        * If de-compressed/extracted in the previous folder, AMUMSS will preserve everything in user folders
          except changes made to AMUMSS files in AMUMSS main, ModScriptCollection and MODBUILDER folders

        * If de-compressed/extracted in a new folder, you can copy/paste these folders from the previous version of AMUMSS
          if you would like to preserve previous work and information...
                + 'Builds'
                + 'ModScript'
                + 'GlobalMEFTI'
                + 'TOOLS\NMSPE_Output'
                + 'TOOLS\SavedSections'
                + 'TOOLS\UNPACKED_DECOMPILED_PAKs'
                + any other files in AMUMSS main not updated by the unzip file

        * You can delete the compressed file from AMUMSS main folder when done extracting

    * EXECUTE BUILDMOD.bat ONCE or more until no more updates are offered
    		+ Always execute BUILDMOD.bat once to re-create all user folders (when they do not exist)
            + it will auto-download\update MBINCompiler.exe and libMBIN.dll

> QUESTIONS

        * Questions are better asked in NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:
                    [https://discord.gg/HFjnmnwe67](https://discord.gg/HFjnmnwe67)
        We have channel #amumss-lua dedicated to AMUMSS/NMSPE with helpful modders and Wbertro#8596 (aka TheBossBoy)

Wbertro
