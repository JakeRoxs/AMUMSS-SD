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

The editable application source is now present under `AMUMSS/`, imported without
source changes from upstream **v5.6.2.0W**. This is the AMUMSS version, not the NMS
version. Upstream describes this release as a full installation for NMS >= 5.5;
compatibility with any particular current game build still requires validation.

**This checkout is not yet a runnable Steam Deck application.** Windows batch
orchestration, bundled-runtime assumptions, and automatic update behavior remain
unchanged. Do not run the upstream launcher in your development checkout: its
self-updater can replace source files. Use a separate disposable runtime directory
for future execution tests, never your only copy of user scripts or game data.

## Repository Layout

- `AMUMSS/BUILDMOD.bat`: upstream Windows entry point.
- `AMUMSS/MODBUILDER/`: build orchestration, Lua processor, helpers, and licenses.
- `AMUMSS/MODBUILDER/HGPAK/HGPAKTool/`: bundled Python archive-tool source.
- `AMUMSS/MODBUILDER/ArrayInfo/ToBuild/`: bundled C# helper source and project.
- `AMUMSS/CONFIG/`, `AMUMSS/README/`, `AMUMSS/TOOLS/`: default configuration,
  upstream documentation, utilities, and learning examples.
- `upstream-release.json`: pinned archive URL, checksum, and source selection policy.
- `scripts/import_upstream.py`: reproducible source importer; never runs imported code.
- `tests/`: repository-tooling tests, not application compatibility tests.
- `docs/todos/`: Steam Deck investigation and implementation work items.

The pre-existing tracked update PAKs and `AMUMSS/TOOL/NMSPE_Output/` data are retained
unchanged. They are historical artifacts, not the source of the imported application.
The upstream release uses `TOOLS/` (plural); the old `TOOL/` tree is separate.

## Reproduce the Source Import

The source files belong in Git, so a normal clone does not need an import step.
To reproduce or verify the baseline, install Python 3.9+ and 7-Zip (`7z` or `7zz`),
download the [pinned release archive](https://github.com/HolterPhylo/AMUMSS/releases/download/v5.6.2.0W/UPDATE.-.5.6.2.0.FULL.7z),
then run from the repository root:

```sh
python3 scripts/import_upstream.py /path/to/UPDATE.-.5.6.2.0.FULL.7z
python3 scripts/import_upstream.py /path/to/UPDATE.-.5.6.2.0.FULL.7z --check
python3 -m unittest discover -s tests -v
```

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
>  >> .lua scripts go into the ModScript folder (created after you run BULDMOD.bat)

>  >> NMS < v5.5, .pak files go into NMS PCBANKS\MODS (a folder you create to use mods with NMS)

>  >> NMS >= v5.5, mod are sub-folders in NMS GAMEDATA\MODS folder

> QUESTIONS
        * Questions are better asked in NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:
                    [https://discord.gg/HFjnmnwe67](https://discord.gg/HFjnmnwe67)                                       
        We have channel #amumss-lua dedicated to AMUMSS/NMSPE with helpful modders and Wbertro#8596 (aka TheBossBoy)

> FOR HELP WITH INSTALLATION:
  Refer to [https://www.nexusmods.com/nomanssky/mods/2626](https://www.nexusmods.com/nomanssky/mods/2626)
  
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
  No worry, it is fast (only depends on your internet speed)

DOWNLOAD and INSTALLATION:
	*** Follow installation instructions found in file at [https://www.nexusmods.com/nomanssky/mods/2626](https://www.nexusmods.com/nomanssky/mods/2626)
	
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
