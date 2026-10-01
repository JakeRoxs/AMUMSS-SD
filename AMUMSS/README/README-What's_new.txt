v5.6.2.0W: released 2025-11-18
  [AMUMSS]:
    [*]CORRECTED: wrong message about creating INDIVIDUAL mods when, in fact, COMBINE mods are created.
    [*]CORRECTED: REPORT.lua showing a 'false bug report' about 'PSARC_LIST_PAKS_MODS.BAT'
    [*]CORRECTED: LocTable.MXML failed to combine all languages files

  [_Check_MODS_Status.bat]: v0.99.6
    ***** BETA VERSION *****
    [*]OUTPUT is found in AMUMSS\MODS_Status.lua file
    
    [*]REMOVED: NOTICE about "ResHandle" sections still in EXML
                "ResHandle" sections are not used by the game and
                do not cause problem if present.
    
  [NMSPE]: v3.3.4.0, .NET 8
    [*]UPDATED: libMBIN.dll used functions
    
v5.6.1.0W: released 2025-10-23
  [AMUMSS]:
    [*]ADDED: code to force LocTable.mxml to be LocTable.MXML in the mod folder
    [*]CORRECTED: processing of scripts when combining
    
  [_Check_MODS_Status.bat]: v0.99.5
    ***** BETA VERSION *****
    [*]OUTPUT is found in AMUMSS\MODS_Status.lua file
    
    [*]CORRECTED: CheckMODS.lua bug calling wrong function name
    [*]CORRECTED: multiple bugs affecting running to completion, in some cases
    [*]IMPROVED: reporting of MBIN in use
    
v5.6.0.0W: released 2025-10-20
  [AMUMSS]:
    [*]ADDED: NOTE: YOU are RESPONSIBLE for deleting sub-folders from previous COMBINE runs in GAMEDATA^\MODS
              to remind users that AMUMSS never deletes anything in GAMEDATA\MODS
    [*]ADDED: missing code to handle adding/changing "_id/_index" of a HOS
    [*]ADDED: Auto-creation of HOES on REMOVE = "SECTION"
              so that MXMLtoEXML does not loose track of the now empty section
    [*]ADDED: write access test to MBINCompilerDownloader folder in TOOLS\Test_CURL.bat
    [*]ADDED: option 'CreateUsefulUtilityScripts' to re-create or not
              TOOLS\Useful Utility Scripts\*.lua after an update. It is 'N' by default.
              After setting to "Y", delete 'MODBUILDER\pak_list.txt' to force a reset.
  set _O=%_O%      -CreateUsefulUtilityScripts N (default)
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: information about the usage of "Seed" values
              See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: the raw "modName.serial.lua" file to 'MODDER_Helper mod' folder for easy access.
              The file shows the exact script as it looks like to AMUMSS.
              Very useful for debugging complex scripts.
              Note: On scripts with very large content, it can add a bit of time to processing.
              This file is generated if option '-SerializeScript' is turned ON in "BUILDMOD_AUTO.bat"
    [*]ADDED: option 'MODSfolderNameScript' to select the name of the mod folder
              as the MOD_FILENAME (default) or the name of the script
  set _O=%_O%      -MODSfolderNameScript N (default)
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADJUSTED: AMUMSS "script processing order" to reflect NMS "normal" processing order.
                 See 'README-AMUMSS_Script_Rules.html'
    [*]CLARIFIED: that "MBIN_FS" can accept any text based type of file
              See 'README-AMUMSS_Script_Rules.html'
    [*]CHANGED: option 'EXPORTED' to activate or not
              this NMS feature. It is now 'N' by default.
  set _O=%_O%      -EXPORTED N (default)
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]CORRECTED: missing closing '}' at end of "NMS_pak_list.txtPretty.lua"
    [*]CORRECTED: creation of valid LocTable.txt from LANGUAGE.EXML that could fail
                  due to some script way of creating the LANGUAGE.EXML files
    [*]CORRECTED: creation of valid MXML/EXML files when the files contain strings with " #"
                  that were partially deleted when using option '-IncludeTagsInEXML_MXML' is "N".
                  Changed special character " #" to " !#".
    [*]CORRECTED: rare occurance in auto-indent code that would misplaced text by one space
    [*]IMPROVED: detection of locked file in CreatedMods folder
    [*]IMPROVED: handling of LocTable files in scripts:
        1) If a LocTable.txt or a LocTable.MXML is in the script folder, 
           it will be used to create the final LocTable.MXML.
           If both are present, they are merged.
        2) If a LocTable.txt and/or a LocTable.MXML are created by the script,
           they are merged with 1).
        3) If one or more LANGUAGE files are modified by the script, 
           they are turned into a merged LocTable.txt with 1) and 2) 
           and used to create the final LocTable.MXML.
        4) Multiple scripts in a COMBINE contribute to 3).
        5) The final LocTable.MXML is used as the language file
           in CreatedMods folder and in the GAMEDATA/MODS mod sub-folder.
        6) The LocTable.txt used to create the final LocTable.MXML is also copied
           to the mod/CreatedMods folders with the scripts used to create the mod.
        7) TOOLS/MODDER_HELPER folder is populated, as usual, with all the files.
              See 'README-AMUMSS_Script_Rules.html'
    [*]REFRESHED: 'README-AMUMSS_Script_Rules.html' on many topics
    
  [_Check_MODS_Status.bat]: v0.99.0
    
    ***** BETA VERSION *****
    [*]OUTPUT is found in AMUMSS\MODS_Status.lua file
    
    [*]ADDED: Checks all MODS in GAMEDATA\MODS folder for conflicts
    [*]ADDED: Forces update of "GCMODSETTINGS.MXML" for accuracy
    [*]ADDED: Lists by "ModPriority" all mods found in GCMODSETTINGS.MXML
    [*]ADDED: Checks for "Malformed mod sub-folder" in GAMEDATA\MODS
    [*]ADDED: Reports MODS using same "EXML" files (for info)
    [*]ADDED: Reports MODS using same "MBIN" files and suggests "HOW to COMBINE" them
    [*]ADDED: Reports MODS using "LocTable.MXML" files and checks for duplicate "Id" in use

  [NMSPE]: v3.3.3.1, .NET 8
    [*]ADDED: back importing missing "MATERIAL" files
    [*]ADDED: NMS version beside libMBIN version
    [*]ADDED: check for existance of Hash for NMS current version and prompt if not exist
    [*]CORRECTED: Importing would, in some cases, import wrong information that would prevent
                  searching correctly when using "Whole" checked.
    [*]CORRECTED: crash in Unpack when paks have duplicate file entries
    [*]IMPROVED: Importing, now using 5 threads
  
v5.4.5.0W: released 2025-07-08
  [AMUMSS]:
    [*]CORRECTED: Prevented adding multiple copies of EXML_FLAGS, EXML_ID and EXML_INDEX to a line.
    [*]CORRECTED: handling of "-IncludeTagsInEXML_MXML N" that would remove some lines
                  from the EXML, in some cases.

  [NMSPE]: v3.1.0.0, .NET 8
    [*]CORRECTED: current line color bug in MXML
    [*]UPDATED: default colors in EXML editor
    [*]UPDATED: showing feedback of Unpacking operation

v5.4.4.5W: released 2025-06-27
  [AMUMSS]:
    [*]UPGRADED: LUA to custom v5.4.8 with lfs support
    [*]ADDED: option 'IncludeTagsInEXML_MXML' to include or not
              '#' tags/EOL comments in EXMLs and MXMLs. It is 'Y' by default.
  set _O=%_O%      -IncludeTagsInEXML_MXML Y (default)
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: exclusion of LocTable.MXML from compiling, for those scripts that
              create the file themselves using 'FILE_CONTENT'
    [*]ADDED: SECADD_COMMENT and VCT_COMMENT to MXML_CT
              See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: LocTable.txt, when existing, to "CreatedMods" folder, if the script is included
    [*]ADDED: detection of NMS pak types pre-5.5
    [*]CORRECTED: saving backups of 'REPORT.lua' to 'TOOLS\REPORTS_BACKUP' folder
    [*]CORRECTED: bug in autoAdjustIndentation code that caused a runaway indentation
    [*]CORRECTED: bug when using MBIN_FS syntax #3 'REMOVE' flag during false attempt to create an EXML
    [*]IMPLEMENTED: reset of cached MXMLs when switching from/to a custom MBINCompiler
    [*]IMPROVED: EXML auto-creation accuracy and speed
    [*]REVERTED: change to script and mod folder case
    [*]REMOVED: some leftover debug information
    [*]UPDATED: BUILDMOD to v.2.0.7

  [NMSPE]: v3.0.6.0, .NET 8
    [*]ADDED: information on removed/changed enum entries in the "Diff report" of libMBIN.dll versions
    [*]ADDED: Reduced version of 'Hash Diff Report' excluding AUDIO and SHADERS folders, when needed
    [*]ADDED: keeping Unpack Folders and Extensions panels open until end of selection process
              (much better then having the panels closing each selection)
    
v5.4.1.1W: released 2025-05-30
  [AMUMSS]:
    [*]ADDED: Full EXML support for 'ENTITY' files that use 'linked='
    [*]CORRECTED: handling of CHANGED values in EXML 'List of Values'
    [*]CORRECTED: handling of <EMPTY> in EXML files
    [*]CORRECTED: handling of ModScript\GlobalMEFTI files (bug introduce after refactoring)
    [*]CORRECTED: bug in EXML creation code that would make processing time 'verrrry' long in some cases
    [*]CORRECTED: message "File not found" on first run of BUILDMOD.bat (finally)
    [*]IMPROVED: handling of _overwrite in EXML files
    [*]UPDATED: BUILDMOD to v.2.0.4
    [*]UPDATED: AMUMSS 'curl.exe' to v.8.13.0

  [AMM]: AMM_ModScript_Manager.exe v1.5.1.0
    [*]ADDED: message to run BUILDMOD.bat once if not done

  [NMSPE]: v3.0.3.0, .NET 8
    [*]CORRECTED: handling of GLOBALS in PAKList tab
    [*]CORRECTED: handling of selected Folders to Unpack

v5.3.5.1W: patched 2025-04-21
  [*]ADDED: missing file for NMSPE

v5.3.5.0W: released 2025-04-21
  [AMUMSS]:
    [*]ADDED: option 'EXPORTED' to activate or not
              this NMS feature. It is 'Y' by default.
  set _O=%_O%      -EXPORTED Y (default)
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: 'AKW' meaning 'AFTER_KEY_WORDS'.
              A new member of 'MXML_CHANGE_TABLE' similar to 'PKW'
              but processed AFTER all other section selection are made.
              See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: information about _index and _id in MapFileTree files
              and FileStructure files
    [*]ADDED: ADD_OPTION = "ADDatLine" to add a line or section AT the line
    [*]ADDED: "EXML_CREATE" to request that EXML files be created
    [*]ADDED: "EXML_FLAGS", "EXML_ID", "EXML_INDEX" to MXML_CT
              to add these special flags to HOS
              See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: ALL line changes to the original MXML are marked in
              the modded MXML with a special flag (like: ' # CHANGED')
    [*]ADDED: ALL lines ADDed to the original MXML are marked in
              the modded MXML with a special flag (like: ' # ADDED')
    [*]ADDED: Auto-creation of EXML files for types of MXML that can be used as EXMLs.
              EXML are used instead of MBIN in the CreatedMODS sub-folders
    [*]ADDED: auto-creation of "LocTable.MXML" from simple script files
              named "LocTable.txt" in the script folder (ModScript or sub-folder)
              When combining, the resulting LocTable.MXML is also combined
              See 'README-AMUMSS_Script_Rules.html' the 'Useful Shortcuts' in 
              'On this tab: USEFUL INFORMATION' section
    [*]CHANGED: 'SECTION_ACTIVE' can now target each values in a List of Values
    [*]CHANGED: 'SECTION_ACTIVE' behavior.  Now starts at '0' to match
                _index="0" of MXML Lists (of Sections or of Values).
                See 'README-AMUMSS_Script_Rules.html'
    [*]CORRECTED: 'WIS' and 'WISS' NOR handling, thanks lyravega
    [*]CORRECTED: Handling of anycase .LUA/.PAK in scripts that would
                  be used in naming MODS sub-folders
    [*]IMPROVED: Handling of "AMUMSS Combine" mods
                 when a generic combine is created
    [*]IMPROVED: Selection of Array sections
    [*]IMPROVED: Selection of a value line from a List of values
    [*]IMPROVED: Detection of List<> in MapFileTree files
    [*]IMPROVED: Creation of MapFileTree files on 2nd thread does not
                 prevent main thread to complete anymore
    [*]INTEGRATED: Handling of LocTable.MXML
    [*]RENAMED: 'TOOLS\EXML_HELPER' to 'TOOLS\MODDER_HELPER'
    [*]RENAMED: 'EXML_CHANGE_TABLE' to 'MXML_CHANGE_TABLE'
    [*]RENAMED: EXT_FUNC 'ModdedEXMLs' to 'ModdedMXMLs'
    [*]REMOVED: _id/_index from SEC_SAVE_TO sections
    [*]UPDATED: BUILDMOD to v2.0.3
    [*]UPGRADED: MakeDictionary.lua language list from static to dynamic
    
  [NMSPE]: v3.0.2.0, .NET 8
    [*]ADDED: font size of search results panel can be changed in 
              menu Options->'Explorer->Search Results Font Size...'
    [*]ADDED: display of libMBIN.dll version on main form
    [*]CORRECTED: a rare exception when closing the app
    [*]CORRECTED: gathering files to unpack when PCBANKS folder contents mod paks
    [*]REWORKED: internal management of Unpacking process

  [AMM]: AMM_ModScript_Manager.exe v1.5.0.0
    [*]ADDED: awareness/handling of folder using '___HIDDEN.txt'
    [*]ADDED: toggling of 'Hide/Show' column
    [*]ADDED: easy setting of 'Hiding/Showing' rows in AMM

v5.0.1.0W: patched 2025-02-03
  [AMUMSS]:
    [*]CORRECTED: ModScript sub-folder references in created MODS

  [Collapse_MODS.bat]: v1.1.0
    [*]ADDED: handling of LocTable.MXML files in MODS
    
  [NMSPE]: v3.0.0.5, .NET 8
    [*]UPDATED: libMBIN tab: 'Fields' are now listed in alphabetical order
    [*]ADDED: detection of incompatible libMBIN.dll version

v5.0.0.0W: released 2025-02-01
  [Collapse_MODS.bat]: v1.0.0
    [*]NEW: === EXPERIMENTAL VERSION ===  (Feedback is welcome)
            A tool to collapse GAMEDATA\MODS sub-folders
            into one sub-folder for MBINs (last one wins)
            and multiple sub-folders for EXMLs.
            Collapse follows the load order
            dictated by the MODS sub-folders names.
            
            After Collapse, all original sub-folders are gone,
            only their content is found in the Collapsed sub-folders

  [AMUMSS]:
    [*]UPGRADED: to new NMS way of handling 'GAMEDATA/MODS' and HGPAK
    [*]ADDED: GLOBALS MBINs are auto-copied to root of sub-folder
              until HG corrects the current behavior:
              (some GLOBALS MBINs do not work in sub-folder GLOBALS)
    [*]ADDED: option 'TABtoSPACES' to specify how many spaces TABs convert to
  set _O=%_O%      -TABtoSPACES 2
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: option to compress backups of mods as .pak, .zip or .7z
  set _O=%_O%      -BackupType pak
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: 'Lang_Shrinker.lua' script to 'TOOLS\Useful Utility Scripts'
              Creates SMALLER LANGUAGE EXML file in 'MODBUILDER\_TEMP\LANGUAGE'
              These will be used as ORIGINALS LANGUAGE files for any script requiring them
    [*]ADDED: 'Auto' updating of 'TOOLS\Useful Utility Scripts\Lang_Shrinker.lua' script
              on AMUMSS / MBINCompiler / NMS updates
    [*]ADDED: LANGUAGE/NMS_LOC9_... to MakeDictionary.lua and Lang_Shrinker.lua scripts
    [*]ADDED: option to show a simple representation of loaded scripts for debugging
  set _O=%_O%      -SHOWSimpleContainer N
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: 'enhanced analysis' of 'NMS_MOD_DEFINITION_CONTAINER' script structure
    [*]ADDED: 'NMS_VERSION' can now be a number without being flagged
    [*]ADDED: 'MOD_CONTRIBUTORS', a string that can be used to recognized contributors
    [*]CORRECTED: behavior of 'WISS': when using 'WISUBSEC_OPTION = ALL' and 'REPLACE_TYPE = ONCE'
                  All sub-sections found by 'WISS' will have one replacment
    [*]CORRECTED: disappearing 'ModScript\ModHelperScripts\Dictionary.lua'
    [*]CORRECTED: 'PKW' behavior skipping some sections in some rare cases
    [*]CORRECTED: minor level error in LANGUAGE MapFileTree files
    [*]OBSOLETE: OPTION -CompressPAK is now OBSOLETE
    [*]OBSOLETE: OPTION -CombinedModType is now OBSOLETE
    [*]UPDATED: 'SKW' to accept empty strings as value like: 'SKW = { "ID", "" }'
    [*]UPDATED: MapFileTree files generation to reflect new 'SKW' behavior above
    [*]UPDATED: BUILDMOD to v.2.0.1
    [*]UPDATED: AMUMSS 'curl.exe' to v.8.11.1
    
  [Check_CONFLICTS_in_MODS.bat]: v1.5.0 (MAY NOT WORK CORRECTLY)
    [*]ADDED: 'Suggested COMBINE groups' based on 'found CONFLICTS'

  [Check_OUTDATED.bat]: v1.1.0 (MAY NOT WORK CORRECTLY)
    [*]CORRECTED: handling of paks in a folder name using lua MAGIC characters
    [*]CORRECTED: handling of paks resolving to the same short names in a folder

  [NMSPE]: v3.0.0.1, .NET 8
    [*]ADDED: About/Information reports if libMBIN.dll is CUSTOM
    [*]ADDED: 'TOOLS\NMSPE_Output\EXMLFailList.txt' file, updated after 'Decompiling' is done
    [*]ADDED: 'CONFIG\KnownNotDecompiling.txt' file, listing depricated .MBIN file that will not decompile
    [*]ADDED: on Decompile: NMSPE now reports depricated files (that did not decompile)
    [*]ADDED: information on depricated .MBIN file at end of Decompiling
    [*]CORRECTED: crash on 'mouse move after selecting' a 'Is Referenced By' entry in libMBIN tab
    [*]CORRECTED: importing of 'LANGUAGE' files data only half done
    [*]CORRECTED: a few misspellings
    [*]IMPROVED: 'Importing'

v4.5.8.2W: patched 2024-10-31
  [AMUMSS]:
    [*]ADDED: detection of missing PATH for PowerShell
    [*]UPDATED: retrieval of NMS version number from NMS.exe
    [*]UPDATED: BUILDMOD to v.1.11.0

v4.5.8.1W: patched 2024-10-28
  [AMUMSS]:
    [*]CORRECTED: launching of auto-update MakeDictionary.lua script on new NMS/MBINCompiler update
    [*]CORRECTED: a rare usage causing a problem loading back a SEC_ADD_NAMED from disk
    [*]CORRECTED: REMOVE could fail, in some cases, and create an EXML file that could not be compiled
    [*]DEPRECATED: option 'MAPFILETREEFORCE'.
                   MAPFILETREE files are always created on 2nd thread or not at all
    [*]REVERTED: code where a HOS is created ouside sections specified by keywords
    [*]UPDATED: nms-amumss-lua-mod-script-collection\TEST_SCRIPTS
    
  [NMSPE]: v2.6.2.0, .NET 8
    [*]CORRECTED: Regression to 'Create Hash Diff of PCBANKS contents' menu

v4.5.8.0W: patched 2024-10-22
  [AMUMSS]:
    [*]ADDED: 'Auto' updating of 'TOOLS\Useful Utility Scripts\MakeDictionary.lua' script
              on NMS / MBINCompiler updates
    [*]ADDED: ADD_OPTION = "REPLACEwholeSECTION" to 'replace' a section with another
              doing a 'REMOVE' and then an 'ADD' in one go
    [*]ADDED: option to start/restart NMS after processing
  set _O=%_O%      -NMSreStart N
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: handling of GEOMETRY files in scripts
    [*]CORRECTED: processing of multiple SKW sections after PKW sections are found
    [*]CORRECTED: rare crash on nil 'scriptname' when bad MBIN filename path was used in script
    [*]CORRECTED: bug in MBIN_FS_DISCARD code that could discard the wrong file depending on the script
    [*]CORRECTED: rare bug in ADD or REMOVE where reverse order would fail to properly order the found sections
    [*]CORRECTED: loading a script, that is using the escape sequence \", would prevent the script from loading
                  and LUAC to report a problem
    [*]CORRECTED: use of regex strings would fail in some circumstances where the standard SED s command separator /
                  was also used in the regexp and replacement strings
    [*]CORRECTED: EXT_FUNC handling of returned EXML extensions
    [*]CORRECTED: failure handling VERY large EXML files (like some GEOMETRY files)
    [*]CORRECTED: in some cases, a HOS would be created ouside sections specified by keywords
    [*]REDUCED: Composite pak name length to 55 
    [*]UPDATED: AUTO_GNH to new EXML file structure in NMS >=5.0
    [*]UPDATED: BUILDMOD to v.1.10.0
    [*]UPDATED: .net version checks
    [*]UPDATED: multiple 'README-AMUMSS_Script_Rules.html' entries, clarifying some usage

  [NMSPE]: v2.6.1.0, .NET 8
    [*]CORRECTED: Unpacking of files with lowercase extensions
    [*]CORRECTED: bug when NMS version ID is missing
    [*]UPGRADED: Scintilla.NET to 5.6.1 (binaries scintilla = 5.5.2, lexilla = 5.4.0)
    
  [Check_CONFLICTS_in_MODS.bat]: v1.4.1
    [*]UPDATED: .net version checks

  [Check_OUTDATED.bat]: v1.0.0 'NEW'
    [*]ADDED: detection of OUTDATED files in paks compared to your current NMS files in paks
    [*]ADDED: by default, 'MODS' folder is checked.  You can add 'other locations' to check by
              adding full paths to file 'CONFIG\OUTDATED_CheckList.txt'
              (one path per line)
              If 'NOMODS' is one of the line in the file, the 'MODS folder' will 'NOT' be checked.

v4.5.7.0W: released 2024-09-04
  [AMUMSS]:
    [*]ADDED: information to ShowSections when SKW/PKW Lua Patterns are in use
    [*]ADDED: information when VALUE_MATCH uses Lua Patterns
    [*]UPDATED: processing of multiple sections after SKW or PKW first sections are found
    [*]CORRECTED: bug in SKW/PWK when using lua Patterns
    [*]CORRECTED: failure to display WARNING about incorrect install folder location, in some cases
    [*]UPDATED: BUILDMOD to v.1.9.11

v4.5.6.0W: released 2024-08-26
  [AMUMSS]:
    [*]ADDED: option to globally control GUIF delays
  set _O=%_O%      -GUIF_DelayMult 1.0
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: option to turn ON-OFF the compressing of created PAKs
              or let the script decide.
              This options can supersedes the script command 'COMPRESS_PAK'
  set _O=%_O%      -CompressPAK Y
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: command 'COMPRESS_PAK'.  See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: VALUE_MATCH "RANGE" capability.  See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: 'MakeDictionary.lua' script to 'TOOLS\Useful Utility Scripts'
              Creates/Updates the 'Dictionary.lua' file in 'ModScript\ModHelperScripts'
              This table can be used in any script by adding to the top of the script:
                       dofile("DICTIONARY.lua")
              The information can be retrieved from table 'DICTIONARY' using
                  the following keys: "source", "name", "icon", "category" 
                  and "description" (if the option is turned ON in the script)
    [*]ADDED: requirement for .NET 8 installation
    [*]COMPLETED: 'EXT_FUNC' function use of MBIN_CT and MBIN_FS.  See 'README-AMUMSS_Script_Rules.html'
    [*]CORRECTED: VALUE_MATCH_OPTIONS "~=" not working when more than one value was used
    [*]CORRECTED: GUIF failure when the 'Wait' parameter is nil or omitted
    [*]CORRECTED: bug in PKW search code that selected wrong section(s) in some cases
    [*]MOVED: "Useful Utility Scripts" folder to 'TOOLS' folder
    [*]REMOVED: 'ImageDictionary.lua' in ModScript\ModHelperScripts folder
                the icon information is now included in 'Dictionary.lua'
    [*]REVISITED: detection of 'Windows Resource Kits\Tools' entry in System PATH
    [*]REVISITED: detection of installation in Desktop or Downloads folders
    [*]UPDATED: 'MapFileTrees' and 'FileStructures' output to match new MBINCompiler output
    [*]UPDATED: In TOOLS: _MapFileMaker.exe, EXML_NameHash_updater.bat and Get_EXML_Tree.bat
                to match new MBINCompiler output
    [*]UPDATED: BUILDMOD to v.1.9.10

  [NMSPE]: v2.6.0.0, .NET 8
    [*]ADDED: sub-menu of 'EXML Options' to select a user 'Import' folder location
              Default is now 'TOOLS\NMSPE_Output\DEFAULT_ImportFOLDER'
    [*]ADDED: a few additional messages to explain behavior of Unpack/Decompile/Import buttons
              in some cases
    [*]ADDED: 'alive' flashing status
    [*]CORRECTED: bug when trying to set custom folders for NMSPE different outputs
    
v4.5.5.0W: released 2024-06-02
  [AMUMSS]:
    [*]ADDED: internal function NormalizePath(pathFilename[,IsStripExtension])
              that normalize filepaths for use in AMUMSS. See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: internal function GetEnvInfo() to return, in your script, some information about
              the AMUMSS/NMS/MBINCompiler environment. See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: new adanced command 'EXT_FUNC'.  See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: option to unpack/decompile the created pak after using 'EXT_FUNC'
              The result is saved in 'TOOLS\UNPACKED_DECOMPILED_PAKs' scriptname folder
  set _O=%_O%      -EXT_FUNC_Helper Y
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]CHANGED: name of 'DoConfigGlobal' option to 'GUIF_AllowRequests' to better reflect its meaning
    [*]CORRECTED: bug preventing some popular scripts from being build
    [*]UPDATED: BUILDMOD to v.1.9.7

  [NMSPE]: v2.5.5.4, .NET 6
    [*]CORRECTED: ToolTips not hiding when app lost focus
    
v4.5.1.0W: released 2024-05-09
  [AMUMSS]:
    [*]ADDED: option to Backup REPORT.lua and log.lua to 'TOOLS\REPORTS_BACKUP' folder
  set _O=%_O%      -BackupReports 10
              See 'README-OPTIONS_DEFINITIONS.txt' for more information
    [*]ADDED: COMMENT at the MBIN_CT level.  See 'README-AMUMSS_Script_Rules.html'
    [*]CORRECTED: Failing with 'LoadAndExecuteModScript.lua:7422, attempt to concatenate a nil value'
    [*]CORRECTED: handling of some scripts that use MBIN_FS alternate syntax #3.
                  In some case the new file was not created correctly in v4.5.0.0
    [*]PREVENTED: creation of a pak when there are only .lua and .txt files to pack
    [*]UPDATED: BUILDMOD to v.1.9.6

v4.5.0.0W: released 2024-05-04
  [AMUMSS]:
    [*]ADDED: to dofile() options 'fullpath folder' with '%AMUMSS_PATH%' internally replaced by the actual AMUMSS MAIN folder path
    [*]ADDED: TEST_SCRIPTS\Test_DOFILE_GUIF.lua to demonstrate/test usage of dofile() various options and GUIF
    [*]ADDED: auto detection of bad System Path and how to correct
    [*]ADDED: TOOLS\FileStructures (which is updated like MapFileTrees) showcasing the 'high level basic structure' of EXML files
              It may help figure out the structure of EXMLs (file is formatted as a python file for easy folding)
              You can change the level of information in FileStructures files using:
              OPTION: -FileStructureLevel 1 (default) (level 2 and 3 are avaiable for more details)
              The option can be ALTERED by adding it to and using BUILDMOD_AUTO.bat,
              copying/pasting the following line will keep FileStructure details to minimum (the default)
  set _O=%_O%      -FileStructureLevel 1
              See 'README-OPTIONS_DEFINITIONS.txt' for more information about the levels
    [*]ADDED: List of paks in MODS folder to REPORT.lua
    [*]ADDED: options 'ONCEINSIDE' and 'ALLINSIDESECTION' to 'REPLACE_TYPE'
              to remove the need for LINE_OFFSET = 1, in some cases
    [*]ADDED: 'SUB_LEVEL' command to help navigate EXML with repeating keywords at the main and sub-levels
              see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: ADD_OPTION = "ADDbeforeSECTION" to add a line or section before a selected section
    [*]ADDED: 'LAST' options to "SECTION_ACTIVE" to choose the last section of all the sections returned
              by the keywords.  See 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: Information about scripts using the problem EXML reported by MBINCompiler when doing a COMBINE
    [*]ADDED: MOD_AUTHOR, LUA_AUTHOR and NMS_VERSION information to log and REPORT files for each script
    [*]CORRECTED: In some rare script configuration, an EXML file, already opened, was not re-flagged for saving to disk
    [*]CORRECTED: nil variable BUG when a script cannot be processed
    [*]CORRECTED: misc. bugs and display inconsistency in log.lua
    [*]IMPROVED: SPECIAL_KEY_WORDS can now accept numbers, they are internally changed to string
    [*]IMPROVED: handling of bad 'NMS_MOD_DEFINITION_CONTAINER' construction (like missing {} or ,)
    [*]IMPROVED: handling of paks in ModScript folder so they are processed only once with multiple scripts
    [*]PREVENTED: processing of paks in ModScript when they are renamed like .pakX (where X is not a dot) to disable them
    [*]UPDATED: 'README-AMUMSS_Script_Rules.html'
    [*]UPDATED: BUILDMOD to v.1.9.4

  [AMM]: AMM_ModScript_Manager.exe v1.4.1.0
    [*]ADDED: in Configurations menu: 'Clear All 1st level InUse' checks

  [NMSPE]: v2.5.5.4, .NET 6
    [*]ENHANCED: on LibMBIN tab, display of structure fields matching EXML legacy ordering
    [*]ENHANCED: libMBIN Diff Report showing ADDED/REMOVED/MOVED fields
    [*]ENHANCED: HASH and LibMBIN Diff creation check for proper file dates current->previous

v4.3.4.1W: released 2024-03-23
  [AMUMSS]:
    [*]MAINTENANCE RELEASE: corrected BUILDMOD.bat replacement order
    [*]RE-ACTIVATED: type 2 pak name for manual combined paks 

v4.3.4.0W: released 2024-03-22
  [AMUMSS]:
    [*]ACTIVATED: WISUBSEC_OPTION = "ALL" with WISS "NOR"
    [*]ADDED: Information about pak(s) to PatchMod content file
    [*]ADDED: Shortcut to 'lfs reference' in 'README-AMUMSS_Script_Rules.html's 'Found on other tabs'
    [*]ADDED: Cleanup of unchanged EXML files before compiling/packing
              based on @CodenameAwesome (aka @Ignacio) script idea. Thanks!
    [*]ADDED: Information about time to execute the internal script code prior to processing the CONTAINER
    [*]ADDED: 'Dictionary.lua' and 'ImageDictionary.lua' to ModScript\ModHelperScripts folder
              These two tables can be used in any script by adding to the top of the script:
                       dofile("DICTIONARY.lua")
                       dofile("ImageDictionary.lua")
              Then, they can be accessed like any lua table is accessed.
              "DICTIONARY.lua" is a table of product, substance, tech, proc tech, reward by ID (the key) and the localized english name (the value).
              "ImageDictionary.lua" is a table by ID (the key) of icon path (the value).
              Thanks to @Mjstral for providing this information.
    [*]ADDED: SPECIAL_KEY_WORDS 'new usage' where it can be a 'table of sub-tables of strings'
              Allowing to apply the same commands to a list of SKW.
              It can be used, as before, with PKW and PRECEDING_FIRST to select sections
    [*]ADDED: PRECEDING_KEY_WORDS 'new usage' where it can be a 'table of sub-tables of strings'
              Allowing to apply the same commands to a list of PKW.
              It can be used, as before, with SKW and PRECEDING_FIRST to select sections
    [*]ADDED: ADD_OPTION = "ADDendSECTION" to add a line or section to the bottom of a selected section
    [*]CHANGED: color from red to yellow for 'LARGE number' and 'BE PATIENT' messages when limiting log.lua output
    [*]CHANGED: integer->float mismatched types from WARNING to NOTICE message
    [*]CHANGED: name of 'PatchMod' files to include pak(s) used instead of script(s) used
                to better reflect why that 'PatchMod' exist. (Content file still list all the scripts used)
    [*]CHANGED: creation of PatchMods so that 'the original mod paks' are no longer required to be
                 placed in MODS
    [*]CORRECTED: combined pak name to be replaced with 'PatchMod' file name when it is a patch
    [*]CORRECTED: type of last 'script to build' in the list prior to 'Starting to process script' #1
                  It would sometimes be the wrong type (Note: that did not interfere with proper processing)
    [*]CORRECTED: VCT 'INLINE MATH_OP' bleeding to other non-inline entries
    [*]CORRECTED: pak count in ModScript when paks are renamed like .pak0 to disable them
    [*]CORRECTED: 'MapFileTree' now report Special keywords correctly (reflecting as case-insensitive)
    [*]CORRECTED: handling of SKW multi-pair keywords
    [*]IMPROVED: reporting of malformed NMS_MOD_DEFINITION_CONTAINER and sub-tables
    [*]IMPROVED: unpacking/decompiling speed for MOD paks with very large number of files
    [*]OBSOLETE: 'FOREACH_SKW_GROUP' is now obsolete, use 'SPECIAL_KEY_WORDS' instead
    [*]REMOVED: Switching to LEAN mode when doing multiple INDIVIDUAL scripts
    [*]UPDATED: BUILDMOD to v.1.9.3
    
  [AMM]: AMM_ModScript_Manager.exe v1.4.0.1
    [*]CORRECTED: path to 'Configurations' folder
    [*]UPDATE: to 'InUse' tooltip

  [NMSPE]: v2.5.4.0, .NET 6
    [*]REMOVED: use of 'Build/x64' folder outside of AMUMSS main folder
    [*]UPGRADED: Scintilla to 5.4.1 and Lexilla to 5.3.0
    
v4.3.3.0W: released 2024-02-19
  [AMUMSS]:
    [*]REMOVED: 'Prompt' unnecessary 'TIMED OUT' "color info" in REPORT.lua
    [*]UPDATED: REPORT.lua handling algorithm, speed improvement in certain hardware configurations
    [*]ENHANCED: 'SEC_EDIT' usage with auto-indentation of the resulting changed section
    [*]CORRECTED: Handling of GUIF() reporting in REPORT.lua (was misplaced outside of script block)
    [*]CHANGED: usage of 'custom' MBINCompiler.exe/libMBIN.dll
              See link 'How to use a CUSTOM MBINCompiler.exe/libMBIN.dll'
              in section 'On this tab: USEFUL INFORMATION...' at the top of
              'README-AMUMSS_Script_Rules.html' for details
    [*]IMPROVED: retrieval algorithm of MBIN/EXML files
    [*]ADDED: Handling of lua some keywords in GUIF's 'Prompt' and COMMENT that were preventing proper folding in REPORT.lua
    [*]ADDED: more comprehensive details of NOTICE/WARNING/ERROR source in REPORT.lua
    [*]UPDATED: BUILDMOD to v.1.9.2
    [*]ADDED: OPTION: -VerboseFinalREPORT Y (default) in REPORT, shows extra information for ERROR/WARNING/NOTICE.
              The option can be DISABLED by adding it to and using BUILDMOD_AUTO.bat,
              copying/pasting the following line will not show extra information for ERROR/WARNING/NOTICE:
  set _O=%_O%      -VerboseFinalREPORT N
              See 'README-OPTIONS_DEFINITIONS.txt' for details
    [*]CORRECTED: DoConfigGlobal option now working again
                  Added a NOTICE when GUIF processing is globally disabled!
    [*]CORRECTED: LEAN mode exhibiting bad behavior some times that could prevent a script to complete
                  or to not show feedback processing was still working
    
  [NMSPE]: v2.5.3.0, .NET 6
    [*]UPDATED: Handling of 'custom' libMBIN.dll found in 'CONFIG\Custom_MBINCompiler' folder
    [*]ADDED: feedback after finishing Unpacking/decompiling files in 'PAK List' tab

v4.3.2.3W: released 2024-02-03
  [AMUMSS]:
    [*]MAINTENANCE RELEASE: updated misc files
  
v4.3.2.2W: released 2024-02-02
  [AMUMSS]:
    [*]MAINTENANCE RELEASE: updated LoadHelpers.lua
  
v4.3.2.1W: released 2024-01-31
  [AMUMSS]:
    [*]UPDATED: BUILDMOD to v.1.9.0
    [*]ADDED: OPTION: -AutoUpdateAMUMSS Y (default) allows AMUMSS to auto-update.
              IT IS HIGHLY RECOMMENDED to allow AMUMSS to auto-update.
              It does not take long in 99.8% of cases.
              The option can be DISABLED by adding it to and using BUILDMOD_AUTO.bat,
              copying/pasting the following line will prompt AMUMSS to ask when an update is detected:
  set _O=%_O%      -AutoUpdateAMUMSS N
              See 'README-OPTIONS_DEFINITIONS.txt' for details

  [MOVED content of 'TOOLS\ModScriptCollection' folder]: 
    [*]to 'TOOLS\ModLuaLearningCollection\These scripts ARE for LEARNING ONLY' folder

  [NMSPE]: v2.5.2.1, .NET 6
    [*]UPDATED: 'Build' folder required by Scintilla is now 'hidden'
    [*]CORRECTED: left side display in libMBIN tab

v4.3.2.0W: released 2024-01-22
  [AMUMSS]:
    [*]UPDATED: BUILDMOD to v.1.8.9 (better detection of 32-bit or 64-bit cmd.exe usage)
    [*]IMPROVED: more compact/clear display of TOOLS\ModScriptCheck serial files content
    [*]ADDED: a 30sec timeout to curl requests
    [*]UPGRADED: VCT functions now accept a table of arguments to the function
    [*]REMOVED: WARNING when a float is equal to the integer value (2000.0 == 2000)
    [*]ADDED: NOTICE when 'INTEGER_TO_FLOAT' is ignored because an operation is not a 'MATH_OPERATION'
    [*]REMOVED: restriction preventing EXML changes to be saved to disk 
                when the last command of an EXML_CT section was ending with SEC_EDIT
                Thanks @lyravega for bringing the point up and for a sharp solution idea
    [*]ADDED: SEC_EMPTY, see 'README-AMUMSS_Script_Rules.html' (thanks @GameMaster-BE)
              Creates an empty 'Saved section' that can be used to 'accumulate' ADD changes
    [*]ADDED: Aliases: 'SEC_COPY' (aka 'SEC_SAVE_TO') and 'SEC_PASTE' (aka 'SEC_ADD_NAMED')
    [*]FIXED: Serialization of script involving 'ADD' taking too long, in some cases
    [*]UPDATED: selene to 0.26.1 with added support for //
    [*]IMPROVED: time needed to update TOOLS\EXML_Helper content
    [*]MISC: improvements to displayed information and code
    [*]ADDED: OPTION: -TestScript Y (default) allow script to be tested.
              IT IS HIGHLY RECOMMENDED to allow testing of scripts.
              It does not take long in 99.8% of cases and greatly helps catching problems.
              The option can be DISABLED by adding it to and using BUILDMOD_AUTO.bat,
              copying/pasting the following line will disable it:
  set _O=%_O%      -TestScript N
              See 'README-OPTIONS_DEFINITIONS.txt' for details
    [*]ADDED: AMUMSS_SUPPRESS_MSG: 'MIXED_TABLE', read about it in README-AMUMSS_Script_Rules.html
    [*]ENHANCED: 'ADD' and 'SEC_ADD_NAMED' usage with auto-indentation of the resulting EXML file
          ==> Scripts no longer need to care about proper indentation in added long strings
              so that modded EXML structure looks good (for humans, MBINCompiler does not care)
    [*]ENHANCED: 'FILE_CONTENT' usage: WHEN the content is proper EXML format
              the resulting EXML file is formated with auto-indentation
          ==> Scripts no longer need to care about proper indentation in added long strings
              so that EXML structure looks good (for humans, MBINCompiler does not care)
    [*]ADDED: "CREATE_HOS" (creates a 'Head Of Section' from a possible section head), see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: "CREATE_HOES" (creates a 'Head Of Empty Section' where a section, that is REMOVED, existed), see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: internal function WFAK() that allows a script creator to 'wait for any key' from the user, see 'README-AMUMSS_Script_Rules.html'
              a custom message can be specified and a wait time to continue without user input
    [*]ENHANCED: LEAN MODE is now leaner!
    [*]ADDED: mow offers to use the script(s) found in a PAK that is being unpacked to re-create/update the pak
    
  [NMSPE]: v2.5.0.0, .NET 6
    [*]IMPROVED: unpacking and decompiling speed

  [Check_CONFLICTS_in_MODS.bat]: v1.4.0
    [*]IMPROVED: processing speed by 1000% or more

  [AMM]: AMM_ModScript_Manager.exe v1.4.0.0
    [*]UPGRADED: to .NET 6
    [*]CORRECTED: number of scripts would sometimes be wrong in the 'InUse' info bubble ('.lua' extension)

v4.3.1.0W: released 2023-10-17
  [AMUMSS]:
    [*]CORRECTED: bug in ADD when using 'Table of Strings'
    [*]UPDATED: BUILDMOD to v.1.8.6
    [*]CORRECTED: GamePass versionid finding code with the help of Discord's @Charlie Mars
    [*]IMPROVED: many cosmetic changes for better display uniformity

  [AMM]: AMM_ModScript_Manager.exe v1.3.5.0
    [*]ADDED: feedback on scripts/paks/mbins/exmls count in use

v4.3.0.1W: released 2023-10-11
  [AMUMSS]:
    [*]UPDATED: Test_CURL.bat to v1.2
    [*]UPDATED: curl.exe to v8.4.0
    [*]UPDATED: BUILDMOD to v.1.8.5
    [*]CORRECTED: code that would switch MBINCompiler version for nothing
                  with a side-effect of clearing MapFileTrees folder
    [*]CORRECTED: catched a possible nil value returned by regex causing a bug
    [*]CORRECTED: missing file of pak content when combining scripts in ModScript only
    [*]ADDED: reporting when AMM / AMM-AUTO is in use
    [*]SIMPLIFIED: mod pak types choices selection (at general demand!)
    [*]ADDED: [TIMED OUT] notice to GUIF()
    [*]OBSOLETE: OPTION -CombinedModType 1 is not used anymore, converted automatically to type 3, if present
    [*]HARMONIZED: colors for ERROR/WARNING/NOTICE/ATTENTION/INFO messages
    [*]ADDED: ~~~~~~~DummyScript.lua to ModScriptCollection folder
    [*]ADDED: OPTION: -UseColorConfig Y (default) to allow to update colors in cmd/terminal window
              The option can be DISABLED by adding it to and using BUILDMOD_AUTO.bat,
              copying/pasting the following line will disable it:
  set _O=%_O%      -UseColorTool N
              See 'README-OPTIONS_DEFINITIONS.txt' for details
    [*]ADDED: OPTION: -UseColorConfigFile AMUMSS_colors.cfg (default used by BUILDMOD.bat)
              This option specifies which CONFIG/?.cfg files to use
              You can create a 'new color configuration file' or edit the original AMUMSS_colors.cfg
        NOTE: AMUMSS may, from time to time, update AMUMSS_colors.cfg
              If you want to use custom colors, you can create your own file and specify that file instead
              See 'README-AMUMSS_colors.txt' for details
              To use the created file, just copy/paste the following line and use BUILDMOD_AUTO.bat:
  set _O=%_O%      -UseColorToolInfo YourNamedFile.cfg
              See 'README-OPTIONS_DEFINITIONS.txt' for details
    
  [NMSPE]: v2.4.5.0, .NET 6
    [*]ADDED: detection of missing IMPORT EXML information
    [*]CORRECTED: Loading the proper libMBIN version depending on Public or Experimental
                  Will detect a change and alert the user
                  REQUIRES a re-start to switch to the other version
    [*]CHANGED: 'Tools/Create Hash of Current PCBANKS' will now auto-show
                the 'Tools/Create Hash Diff of PCBANKS Contents...' dialog when Hash Creation is done
    [*]ADDED: Right-click and Shit-Richt-click to clipboard to 'Search Results' on tab 'Explorer'
    
  [AMM]: AMM_ModScript_Manager.exe v1.3.4.0
    [*]ADDED: auto-selection of INDIVIDUAL mod created when BuildMod button is clicked and AUTO is OFF
              (except where ___COMBINE.txt exist in sub-folders)
              Follows BUILDMOD_AUTO.bat OPTION settings when AUTO is ON
    [*]ADDED: ModScript folder can be 'USE'd or not, the same as all other sub-folders
              When not 'USE'd, scripts, paks, MBIN and EXML in ModScript folder are ignored
              That does not affect sub-folders behavior
    [*]ADDED: 'Configurations' menu, allows to save (and load) the current setup as/from a file

  [MFM]: _MapFileMaker.exe v1.1.2.1
    [*]IMPROVED: added handling of spaces in both AMUMSS and EXML source paths

  [Test_AMUMSS_install.bat]: v1.3.2
    [*]CORRECTED: missing \

v4.3.0.0W: released 2023-08-25
  [AMUMSS]:
    [*]UPDATED: BUILDMOD to v.1.8.3
    [*]ADDED: version info to 'TOTAL TIME to complete'
    [*]ADDED: List<> and Array[] info to MapFileTree Files
    [*]CORRECTED: bug when a called MBIN file does not exist anymore in PCBANKS paks
    [*]CORRECTED: bug when using REGEXBEFORE and REGEXAFTER with some 'strings' with backslashes (thanks @_redmas#4452)
    [*]ADDED: REGEXBEFORE / REGEXAFTER changes and error reporting
    [*]ADDED: reference to AMUMSS version in created paks
    [*]UPDATED: double-backslash are changed to single-backslash in all ADD strings
    [*]ADDED: SEC_UNSAVED, see 'README-AMUMSS_Script_Rules.html' (thanks @DarkScythe)
    [*]ADDED: scripts, using VCT functions(), can now dynamically add new EXML_CT sections
              to the current and later EXML_CT sections of the script
              that will be processed as if they had been in the original script. (thanks @DarkScythe)
    [*]ADDED: For scripts that use VCT functions(), a .postserial.lua file can be generated
              in addition to the .serial.lua file currently generated when
              OPTION -SerializeScript is 'Y' (can be changed in BUILDMOD_AUTO.bat).
              The .serial.lua file shows the resulting CONTAINER for the original script
              and .postserial.lua shows the resulting CONTAINER after the script is processed by AMUMSS
              (showing the VCT functions() dynamically created EXML_CT, if any)
    [*]ADDED: OPTION: -IncrementalBuilds 3  -- number of IncrementalBuilds to keep (default is 3)
              The option can be added to the user BUILDMOD_AUTO.bat, just copy/paste the following line:
  set _O=%_O%      -IncrementalBuilds 3
              See 'README-OPTIONS_DEFINITIONS.txt' for details
    [*]IMPROVED: AMUMSS does not try to switch to the other MBINCompiler if Latest and Public are identical
                 improves decompiling speed by 50% when it cannot decompile all files
    [*]IMPROVED: Unpacking speed greatly improved (unless OPTIONS -DEVMODE is 'F'ull)
    [*]CHANGED: Unpacking is done directly in the TOOLS\UNPACKED_DECOMPILED_PAKs in a folder named as
                the pak.
    [*]ADDED: OPTION: -UseLastCompiler (default is 'Y') try to use the last compiler.exe that was able to decompile a file
              If 'N', when unpacking to TOOLS\UNPACKED_DECOMPILED_PAKs a pak in Modscript
                      AMUMSS will NOT use the last compiler.exe that was able to decompile a file,
                      but will try to find a better compiler.exe for the next file.
                      IT WILL TAKE MORE TIME TO UNPACK THE PAK FILE, BUT the decompiling may be MORE ACCURATE.
              The option can be added to the user BUILDMOD_AUTO.bat, just copy/paste the following line:
  set _O=%_O%      -UseLastCompiler Y
              See 'README-OPTIONS_DEFINITIONS.txt' for details
      
  [Check_CONFLICTS_in_MODS.bat]: v1.3.0
    [*]ADDED: version info to 'TOTAL TIME to complete'

  [AMM]: NEW VERSION: AMM_ModScript_Manager.exe to v1.3.3.0
    [*]ADDED: auto-selection of INDIVIDUAL mod created when BuildMod button is clicked
              (except where ___COMBINE.txt exist in sub-folders)
    [*]ADDED: double-clicking 'ModScript' will only show files in ModScript folder
              (*.lua, *.pak, *.MBIN, *.EXML, GlobalMEFTI\*.* and ModHelperScripts\*.*)

  [NMSPE]: v2.4.3.0, .NET 6
    [*]ADDED: detection of inaccessible PCBANKS files

  [RemoveTrailingSpacesNon-empty.bat]: v1.0.1
    [*]NEW: A drag/drop utility to mainly clear trailing space from txt-like files
  
  [MFM]: _MapFileMaker.exe v1.1.2.0
    [*]MOVED: app to TOOLS folder
    
  [MOVED to MODBUILDER folder]: 
    [*]bzrun.bat and renamed bzrunM.bat
    
  [MOVED to ModScript folder]: 
    [*]ModExtraFilesToInclude folder and renamed GlobalMEFTI
    
  [MOVED to CreatedModPAKs folder]: 
    [*]Builds folder and renamed BuildHistory
    
  [MOVED to CONFIG folder]: 
    [*]DateTimeFormat.txt
    [*]NMS PCBANKS Explorer.ini
    [*]NMS_FOLDER.txt
    
  [MOVED to TOOLS folder]: 
    [*]EXML_NameHash_updater.bat and output folder
    [*]Get_EXML_Tree.bat and output folder
    [*]Log_file_cleaner.bat
    [*]NMS_FULL_pak_list.txt
    [*]NMS_pak_Dir.txtPretty.lua
    [*]NMS_pak_list.txtPretty.lua
    [*]RemoveTrailingSpacesNon-empty.bat and output folder
    [*]Test_AMUMSS_install.bat
    [*]Test_CURL.bat
    [*]MapFileTrees folder
    [*]ModScriptCheck folder
    [*]ModScriptCollection folder
    [*]NMSPE_Output folder
    [*]SavedSections folder
    [*]UNPACKED_DECOMPILED_PAKs folder
    
v4.2.2.3W: released 2023-07-18
  [Check_CONFLICTS_in_MODS.bat]: v1.2.1
    [*]CORRECTED: list of paks in MODS folder not being refreshed properly

  [NMSPE]: v2.4.2.7, .NET 6
    [*]ADDED: detection of inaccessible PCBANKS files
    
v4.2.2.2W: released 2023-07-17
  [AMUMSS]:
    [*]CORRECTED: various bugs and messages related to .NET

  [Check_CONFLICTS_in_MODS.bat]: v1.2.0
    [*]CORRECTED: messages related to .NET
    [*]CORRECTED: missing conflicts detection flag

  [Test_AMUMSS_install.bat]: v1.3.0
    [*]UPDATED:  messages related to .NET

v4.2.2.1W: released 2023-07-16
  [AMUMSS]:
    [*]CORRECTED: new GetFreshSources code not handling correctly other types of files than .MBIN
    [*]ADDED: 'README-AMUMSS_Script_Rules.html' clarification of 'MBIN_FS' usage of text based files
    [*]CORRECTED: date detection failing for certain date formatting

v4.2.2.0W: released 2023-07-15
  [AMUMSS]:
    [*]IMPROVED: VCT Inline MATH_OP to allow "@+6", "@+-6","@++6" and other variations with *, /, //, %, ^
    [*]IMPROVED: processing speed on script 1st pass now on par with subsequent passes
    [*]CHANGED: # of Incremental Builds from 9 to 3
    [*]CORRECTED: BUG truncating some string values in MapFileTree files
    [*]ADDED: MapFileTree files now also show LANGUAGE files values in 'Plain Text'
        ex.:[.SU:   25710: 3]  | | {"Id","UI_ROBO_CAMP_RES",},
           :[P..:   25711: 3]  | | "English",
           :[.SU:   25712: 4]  | | | {"Value","... &lt;SPECIAL&gt;accord&lt;&gt; ...&lt;NEWLINE&gt;&#xA;... harmonic seal: &lt;TRADEABLE&gt;deactivated&lt;&gt; ...",},
           :[   plain test  ]  | | | {"Value","... <SPECIAL>accord<> ...<NEWLINE>|NL|... harmonic seal: <TRADEABLE>deactivated<> ...",},
    [*]CORRECTED: files randomly disappearing from MODBUILDER\_TEMP\DECOMPILED folder
    [*]UPDATED: selene to 0.25.0 with added support for math.tointeger
    [*]ADDED: ~ (tilde) to front of patch name
    [*]ADDED: .NET 6 installation or, on failure, request for installation
    
  [Check_CONFLICTS_in_MODS.bat]: v1.1.1
    [*]IMPROVED: processing speed x10
    [*]ADDED: .NET 6 installation or, on failure, request for installation

  [EXML_NameHash_updater.bat]: v1.0.0
    [*]NEW: Drag and drop .EXML file^(s) and/or folder^(s) on batch file to UPDATE all NameHash values
            Updated EXML are found in 'NameHashUpdated' folder

  [AMM]: NEW VERSION: _ModScript_Manager.exe to v1.3.2.3
    [*]IMPROVED: flashing STOPS on mouse hover when detecting DIASBLEMODS.TXT in PCBANKS (click to open PCBANKS)

  [MFM]: NEW VERSION: _MapFileMaker.exe v1.1.1.0
    [*]UPDATE: Feedback on progress
    [*]IMPROVED: processing speed x10

  [NMSPE]: NEW VERSION: NMSPE v2.4.2.5, .NET 6
    [*]CORRECTED: fatal bug when a mod pak is erroneously present in PCBANKS instead of PCBANKS\MODS
    
============ OLDER VERSIONS ===========
v4.2.1.4W:
  [AMUMSS]:
    [*]IMPROVED: SKW processing time from 17.7 sec to 0.046 sec for a script selecting 894 sections
    [*]IMPROVED: ModScript sub-folders can now be 3 levels deep
    [*]IMPROVED: SKW becomes a FSKWG automatically instead of throwing a WARNING
                 when written with the proper syntax
    [*]IMPROVED: MapFileTree files with information concening EXML lines with only 'name = ' or 'value=' as possible 'HOES'
                 see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: AUTO_GNH command to instruct AMUMSS to auto-generate NameHash from the preceding line value of an ADD
    [*]ADDED: 'GNH(name as string)', an internal function to request the NameHash of a string
              Can be used in a script body AND in VCT
    [*]ADDED: "script's functions" access from VCT to process the current value as desired (thanks @lMonk),
              see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: INLINE math operation in VCT (thanks @lyravega), see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: CUSTOM_ORDER command to allow specifying the processing order of:
                       SECTION_UP, SECTION_ACTIVE, WIS and WISS
    [*]ADDED: Information on how to target HOES ("Head Of Empty Section") in EXML in 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: REMOVE = "HBOS" (remove Head and Bottom Of Section), see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: new WARNING when an ADD operation points to the last line of the EXML file, i.e.: '</Data>'
    [*]ADDED: new WARNING when .pak files are in GAMEDATA\MODS (instead of GAMEDATA\PCBANKS\MODS)
    [*]IMPROVED: LINE_OFFSET to accept NUMBER or STRING in a table
    [*]ENHANCE: allow dofile() filepath to be relative to the calling script folder
    [*]ENHANCE: detection of missing libMBIN.dll
    [*]REMOVED: libMBIN.dll and libMBIN.previous.dll from AMUMSS main folder
    [*]REMOVED: 3-5 sec delay after "Ding" and before "Press any key" message at end of processing
    [*]CORRECTED: Handling of NAMED_SECTION to allow access to first two lines
    [*]CORRECTED: a bug that targeted some times more sections than requested when doing SKW+PKW
    [*]REMOVED: NOTICE about numbers being so big that MBINCompiler may turn them into scientific notation

  [MFM]: NEW app: _MapFileMaker.exe v1.1.0.0 ( a.k.a. MFM )
    [*]NEW: drag/drop console app to create MapFileTree files in MapFileTrees folder from .EXML files
    [*]ADDED: folders can also be dropped
    
  [AMM]: NEW VERSION: _ModScript_Manager.exe to v1.3.2.2
    [*]IMPROVED: ModScript sub-folders can now be 3 levels deep, see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: ___HIDDEN.txt flag to hide a ModScript folder from AMM (needs to be manually created)
    [*]ADDED: flashing detection of DIASBLEMODS.TXT in PCBANKS (click to open PCBANKS)
    [*]IMPROVED: QOL
    
  [NMSPE]: NEW VERSION: NMSPE v2.4.2.4, .NET 6
    [*]ADDED: in Tools menu: 'Create libMBIN Diff' files to easily be able to see added/removed fields from structures
              after libMBIN.dll is updated
    [*]MOVED: libMBIN.dll to MODBUILDER folder
    [*]ADDED: Blocked Importing of SWITCHDATA for search purposes
    [*]ADDED: .NVN file extension
    [*]ADDED: .ANIM.MBIN extension to menu Unpack Options->Include Files with Extension
    [*]ADDED: folder FONTS
    [*]IMPROVED: Explorer tab: EXML search result display speed, even with thousands of results found
    [*]IMPROVED: Explorer tab: EXML search time for first search and subsequent ones
    [*]ADDED: Handling of files when unpacking and decompiling MAIN points to the same folder
    [*]ADDED: when Unpacking: auto-creation of a file listing NMS files that 
              have mismatched GUID compared to MBINCmpiler.exe/libMBIN.dll (and NMS.exe)

v4.1.1.0W:
  [AMUMSS]:
    [*]CORRECTED: a severe bug preventing changes to files from being written to disk
                  It is RECOMMENDED to re-process scripts done with v4.1.0.4W just in case!

v4.1.0.4W: Internal maintenance only
v4.1.0.3W: Internal maintenance only

v4.1.0.2W:
  [NMSPE]: NEW VERSION: NMSPE v2.3.1.0, .NET 6
    [*]ADDED: in menu Tools/'Open Diff Folder...' in explorer.exe
    [*]MOVED: NMSPE output of Diff, libMBIN_Content and PAK_Content to AMUMSS sub-folder TOOLS\NMSPE_Output for a cleaner main folder
    [*]IMPROVED: general speed and responsiveness
    [*]IMPROVED: High DPI handling
    
  [AMM]: NEW VERSION: _ModScript_Manager.exe to v1.2.4.0
    [*]EXCLUDED: ModHelperScripts folder from internal processing
    [*]ADDED: Delay to reduce BuildMod button involuntary spamming 

  [AMUMSS]:
    [*]IMPROVED: General processing speed for every script
    [*]NEW: MBIN_FS_DISCARD (member of EXML_CHANGE_TABLE).  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
    [*]CHANGED: ADD_FILES =>> 'FILE_DESTINATION' can now be a STRING or a (TABLE of STRINGs), see 'README-AMUMSS_Script_Rules.html'
    [*]ENHANCED: "ADD" can now be a TABLE of strings or still a STRING (as before)
    [*]UPDATED: selene to version [0.24.0] - 2023-01-10
    [*]ACTIVATED: SEC_SAVE_TO, SEC_KEEP, SEC_EDIT and SEC_ADD_NAMED can now be used, see 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: WI_SEC_LOP = "NOR".  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: WISUB_SEC_LOP = "NOR".  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: AMUMSS_SUPPRESS_MSG: UNUSED_VARIABLE, read about it in README-AMUMSS_Script_Rules.html
    [*]ADDED: AMUMSS_SUPPRESS_MSG: UNDEFINED_VARIABLE, read about it in README-AMUMSS_Script_Rules.html
    [*]ADDED: 'NamedValue' as an OPTIONAL 3rd string to VCT sub-tables, read about it in README-AMUMSS_Script_Rules.html
              It allows recording the value of a 'Property name/value' for later use in the same or any following script
              being currently processed
    [*]ADDED: Time out on GUIF() so that script processing can continue with default values when unattended
    [*]ADDED: "sed 's' Command" 'flags' as a 3rd optional argument in REGEXBEFORE and REGEXAFTER
              and a direct url link to the "sed s Command" web page in 'README-AMUMSS_Script_Rules.html'
    [*]ADDED: 'dofile()' handling to allowed script general functions to be re-used with other scripts
              Read about it in 'README-AMUMSS_Script_Rules.html' under 'Which parts of LUA language can I use in scripts?'
    [*]ADDED: Checking that mods extension are in LOWERCASE in MODS folder, when doing Conflict checking
              Otherwise, NMS will not use them!  README updated.
    [*]ENHANCED: error message that 'curl.exe' cannot access the web to check if an update exist for MBINCompiler.exe/libMBIN.dll
    [*]CORRECTED: a bug where some scripts with extension .LUA (uppercase) where not flagged as valid scripts
    [*]CORRECTED: a bug pertaining to 'too-deep' folders in ModScript
    [*]CORRECTED: a possible erroneous display of MBIN name during unpacking

v4.0.4.0W:
  [*]NEW VERSION: NMSPE v2.2.5.0, .NET 5
    [*]ADDED: In Tools menu: 2 new functions to create
      a) Hash of your current PCBANKS content
      b) a Diff files between hashes of different versions of NMS (very fast)
      c) custom folder locations for a) and b)
    [*]ADDED: '.\PAK_Content\Hash_vx.x.x.x.json' files with hash values of NMS pak files content
            that can be used to compare with preceding version for file changes/additions
        BONUS content includes Hash files for NMS version 95450 to 95961

v4.0.3.0W:
  [*]NEW VERSION: NMSPE v2.2.1.0, .NET 5

v4.0.2.0W:
  [*]NEW VERSION: NMSPE v2.2.0.0, .NET 5
  [*]ADDED: '.\libMBIN_Content\Content_libMBIN_vx.x.x.x.lua' file that reports all structures and fields in a simple format
            that can be used to compare with preceding version for name changes/additions
  [*]CORRECTED: NMSPE memory leak while decompiling
  [*]CORRECTED: NMSPE always selecting one file in PAKList tab

v4.0.1.0W:
[*]ADDED: created pak name 'info' to Report.lua

v4.0.0.9W:
  [*]ADDED: Option: -GameVersion: To ask the user if their NMS game files are '(P)ublic' or '(E)xperimental'
            the option can be added to the user BUILDMOD_AUTO.bat, just copy/paste the following line:
  set _O=%_O%      -GameVersion ASK
            See 'README-OPTIONS_DEFINITIONS.txt' for details
  [*]ENHANCED: Hopefully getting feedback about the user game files vwill eliminate most problems
            with automatically using the right vof MBINCompiler.exe

v4.0.0.8W:
  [*]CORRECTED: missing reset of MODBUILDER/_TEMP folder when a new vof MBINCompiler.exe is downloaded

v4.0.0.7W:
  [*]REMOVED: pause command after MBINCompiler check

v4.0.0.6W:
  [*]CORRECTED: fetching the right MBINCompiler.exe version for public/experimental
  [*]ADDED: reference to '-DoConfigGlobal' in default OPTIONS list

v4.0.0.5W:
  [*]UPDATE: Better handling of multiple ModScript sub-folders with/without MEFTI folders
  [*]ADDED: "//", "%" and "^" as valid MATH_OPERATION
  [*]ADDED: "!" as a valid option to F/FB type MATH_OPERATION
  [*]ADDED: information, in the Script Rules, about "Which parts of LUA language can I use in scripts?"
  [*]ADDED: an internal function GUIF() that allows a script creator to ask the script user for alternate script values
  [*]ADDED: action button 'BUILDMOD' to AMM (ModScript_Manager) to execute BUILDMOD/BUILDMOD_AUTO.bat
  [*]ENHANCED: LINE_OFFSET behavior to include LINE_OFFSET = 0 which is now different than having NO LINE_OFFSET entry in an EXML_CT sub-table
  [*]UPDATED: README-AMUMSS_Script_Rules.html to reflect changes
  [*]CORRECTED: bad path to delete DISABLEMODS.txt

v4.0.0.4W:
  [*]NEW: 'Alias names' for INTEGER_TO_FLOAT ('ITF') and MATH_OPERATION ('MATH_OP')
  [*]ADDED: Info -> "What do 'Script to build' types mean?" to README Script Rules
  [*]UPDATED: ModScript_Manager.exe to v1.2
  [*]ENHANCED: dotnet install drive detection
  [*]UPDATED: Test_AMUMSS_install.bat to v1.2.2
  [*]UPDATED: BUILDMOD.bat to v1.4

v4.0.0.3W:
  [*]REMOVED: some debugging info

v4.0.0.2W:
  [*]CORRECTED: wrong name of pak when combining only one script under certain conditions
  [*]UPDATED: alias names to members in "Simplified Hierarchy of 'NMS_MOD_DEFINITION_CONTAINER'" of README

v4.0.0.1W:
  [*]ADDED: Option: -SOUND = 'Y': meaning use SOUND
            see 'README-OPTIONS_DEFINITIONS.txt'
  [*]ADDED: Option: -CLEANLOG = 'Y': meaning clean log.lua of escape sequences if allowed
            see 'README-OPTIONS_DEFINITIONS.txt'
  [*]UPDATED: Check_CONFLICTS.bat (same functionnality + checks for .NET proper v+ reports game/exe version)
  [*]CORRECTED: a rare bug that prevented a script section without an EXML_CHANGE_TABLE, 'after' a previous section
                with an EXML_CHANGE_TABLE, from processing the right EXML (thanks @Lenni009)

v4.0.0.0W:
  [*]ENHANCED: Compiling speed with vof MBINCompiler.exe >= 3.84.0.1
  [*]UPGRADED: LUA to custom v5.4.4 with lfs.currentdir support
  [*]NEW: 'README-AMUMSS_Script_Rules.html' now browser friendly ->> 'supersides' all previous 'Script Rules' files
  [*]NEW: a '___DONOTUSE.txt' file in a first level sub-folder of ModScript will instruct AMUMSS 
            to IGNORE that sub-folder and ALL its content: files and sub-folders
  [*]NEW: a '___COMBINE.txt' file in a sub-folder of ModScript will instruct AMUMSS 
            to AUTO_COMBINE the scripts in that sub-folder
  [*]NEW: FOREACH_SKW_GROUP (member of EXML_CHANGE_TABLE).  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
  [*]NEW: NOTICE_OFF (member of EXML_CHANGE_TABLE).  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
  [*]NEW: WI_SEC_LOP (member of EXML_CHANGE_TABLE).  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
  [*]NEW: WISUB_SEC_LOP (member of EXML_CHANGE_TABLE).  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
  [*]NEW: WISUB_SEC_OPTION (member of EXML_CHANGE_TABLE).  Read all about it in the new 'README-AMUMSS_Script_Rules.html'
  [*]NEW: 'Alias names' for PRECEDING_KEY_WORDS ('PKW'), SPECIAL_KEY_WORDS ('SKW') and VALUE_CHANGE_TABLE ('VCT')
  [*]NEW: 'README-What_are_ShowExtraSections.txt' to explain what is the meaning of those 'ExtraSections' when turned ON
  [*]NEW: COMMENT, a STRING comment that the modder can make appear in the cmd window and REPORT.lua
            for the current EXML_CHANGE_TABLE sub-table (suggested by CopperBoltwire#0745 on Discord)
  [*]NEW: 'EXML's in ModScript can be used to override PCBANKS generated files with scripts
            Also can be used without scripts to create a GENERIC.pak (that you should rename)
  [*]ENHANCED: SPECIAL AND PRECEDING 'KEYWORDS' are now fully case-insensitive
  [*]ENHANCED: MapFiletree files now include more information
  [*]ENHANCED: MapFiletree LANGUAGE files are especially processed to reduce the line count to 5.5% 
               compared to the original line count (like 30706/552642 lines) and to speed up their creation.
  [*]ENHANCED: VALUE_MATCH can now use LUA's regular string expressions interpreted as LUA 'Patterns'
               Read all about it in 'README-AMUMSS_Script_Rules.html'
  [*]ENHANCED: VALUE_MATCH is case-insensitive
  [*]ENHANCED: VALUE_MATCH can be a table of strings where each string can trigger a replacement if matching
  [*]ENHANCED: VALUE_CHANGE_TABLE can now use LUA's regular string expressions interpreted as LUA 'Patterns'
               Read all about it in 'README-AMUMSS_Script_Rules.html'
  [*]ENHANCED: in VALUE_CHANGE_TABLE (at Lenni's request), 
               - if a '+' is added at the front of 'newvalue' like '+newvalue'
                 then the 'newvalue' is concatenated to the end of the old 'value'
               - if a '+' is added at the end of 'newvalue' like 'newvalue+'
                 then the 'newvalue' is concatenated to the start of the old 'value'
  [*]ENHANCED: VALUE_CHANGE_TABLE 'Property name/value=' is case-insensitive
  [*]ENHANCED: MATH_OPERATION SUFFIX L: and LB: now accept '!' to lock the first value found
               Read all about it in the new 'README-AMUMSS_Script_Rules.html'
  [*]ENHANCED: CONTAINER matching bracket analysis
  [*]IMPROVED: windows's curl.exe will be used if found in system32 (removing one problem with AV)
  [*]IMPROVED: call to windows\system32\find.exe so that Cygwin's find.exe (and others) cannot be used instead
            causing AMUMSS to target the wrong file (see https://cygwin.com/cygwin-ug-net/using-effectively.html)
  [*]ADDED: to ADD_FILES section: INTERNAL_FILE_SOURCE (adds files from NMS 'original' PCBANKS paks)
  [*]ADDED: WARNING in 'README-Creating_a_Patch_for_existing_MOD_PAKs.txt' about mod paks using 'older' MBINs
  [*]ADDED: Information about 'empty' folders in your 'GAMEDATA\PCBANKS\MODS' folder that can 'crash' NMS
            see 'README-AMUMSS_Script_Rules.html': "About 'empty' folders in your 'GAMEDATA\PCBANKS\MODS' folder" 
  [*]ADDED: internal ability to automatically remove obsolete AMUMSS files
  [*]ADDED: Check of .NET Desktop Runtime 5.?.?? Windows x64 install (or 'lack of' and request to user to do so!)
  [*]ADDED: MOD_MAINTENANCE, a STRING to indicate who is doing the maintenance of this script
            (as used  by Babscoole on Discord)
  [*]ADDED: Handling of sub-folder 'MEFTI' of your 'custom script folder',
            Files in this folder will be automatically included in the final PAK.
            A 'custom script folder' is a sub-folder of ModScript that includes ALL parts 
        of your mod (.lua script and extra files in its 'MEFTI' folder)
        just like the 'ModScript\GlobalMEFTI' folder is for all scripts
  [*]ADDED: pak content listing to report when unpacking a pak file to 'TOOLS\UNPACKED_DECOMPILED_PAKs' folder
  [*]ADDED: Option: -ReCreateMapFileTree = 'X': meaning NEVER create MapFileTree files (if you do not use them)
  [*]ADDED: Option: -DEV_MODE F   --FULL mode: instruct AMUMSS to generate ALL information in cmd window
                      (slowest, with full feedback to modder)
                    -DEV_MODE D   --DEVELOPMENT mode: instruct AMUMSS to generate ALL 'helper' files
                      (medium, but adequate information to modder in the cmd window)
                    -DEV_MODE L   --LEAN mode: AMUMSS only generates files necessary to produce the mods
            (fastest, much less information to user in the cmd window)
              In any DEV_MODE: ALL information is still in Report.lua
        -DEV_MODE option can be manually added to BUILDMOD_AUTO.bat if the user whishes
  [*]ADDED: AMUMSS_SUPPRESS_MSG, read about it in README-AMUMSS_Script_Rules.html
  [*]RENAMED: 'ADD_NAMED_SECTION' renamed to 'SECTION_ADD_NAMED' (old name retained for backward compatibility)
  [*]RENAMED:      'EDIT_SECTION' renamed to 'SECTION_EDIT'      (old name retained for backward compatibility)
  [*]RENAMED:      'KEEP_SECTION' renamed to 'SECTION_KEEP'      (old name retained for backward compatibility)
  [*]RENAMED:   'SAVE_SECTION_TO' renamed to 'SECTION_SAVE_TO'   (old name retained for backward compatibility)
  [*]CORRECTED: a bug in REGEXBEFORE and REGEXAFTER involving '\\' (thanks DeadMoroz#9600 on Discord)
  [*]CORRECTED: improper folding of REPORT.lua when message 'No replacement done. Please verify your script' was present
  [*]CORRECTED: a bug made WHERE_IN_SECTION and WHERE_IN_SUBSECTION to skip every two entries
  [*]CORRECTED: a bug that made BUILDMOD.bat very slow to start some times

v3.9.5.98W:
  [*]UPDATED: PRECEDING_KEY_WORDS internal algorithm (it was, some times, incorrectly returning more sections than it should)
  [*]REMOVED: some unnecessary NOTICES when multiple sections are found and SECTION_ACTIVE is in use
  [*]CLARIFIED: SECTION_ACTIVE rule when SECTION_ACTIVE = '0'

v3.9.5.97W:
  [*]UPDATED: SECTION_ACTIVE
  [*]UPDATED: PRECEDING_KEY_WORDS internal algorithm (it was, some times, incorrectly returning more sections than it should)
  [*]REMOVED: some unnecessary NOTICES when multiple sections are found and SECTION_ACTIVE is in use
  [*]CLARIFIED: SECTION_ACTIVE rule when SECTION_ACTIVE = '0'

v3.9.5.96W:
  [*]CORRECTED: some MBINCompiler error reporting causing problems with the collapsible Report.lua
  [*]ALLOWED: more relaxed ways to write script properties like VALUE_MATCH, VALUE_MATCH_TYPE and others
  [*]ALLOWED: script files encoded with 'CR' only to still be processed correctly
          Windows uses two characters the CRLF sequence; Unix only uses LF
          and the old MacOS ( pre-OSX MacIntosh) used CR.
  [*]OPTIMIZED: MapFileTree creation on 2nd thread
  [*]CORRECTED: Uninitialized variable missing in a sub-function and pass back to the calling function
          as a nil that went undetected because I was using it as a boolean in a code block

v3.9.5.95W:
  [*]TEST: Testing AMUMSS update package source

v3.9.5.94W:
  [*]SWITCHED: AMUMSS update package source

v3.9.5.93W:
  [*]IMPROVED: AMUMSS updating simplified.  Distinct update packages reduce download times

v3.9.5.92W:
  [*]ADDED: BUILDMOD.bat can NOW be updated like the rest of AMUMSS when BUILDMOD.bat is executed

v3.9.5.91W:
  [*]CORRECTED: removed extra NOTICEs about multiple sections found
  [*]CORRECTED: curl complaining about 'no URL specified!' after getting MBINCompiler.exe/libMBIN.dll

v3.9.6W:
  [*]ADDED: 'New update available' message at BUILDMOD.bat starts

  [*]ADDED: reporting of failed scripts at end of REPORT.lua
  [*]ADDED: to *.pak_content.txt file when such a file is created, ex.:
      Original information:
         MOD FILENAME: ThisMaster.pak
         MOD AUTHOR: Ignacio
         LUA AUTHOR: Unknown
      MOD DESCRIPTION: is the original requester for this added information
        NMS VERSION: 3+
        
  [*]IMPROVED: 'REPORT.txt' renamed to 'REPORT.lua' with collapsable sections for each script/MBIN processed and the Conflict section
  [*]IMPROVED: when using option '-SerializeScript Y' (default is 'N'), the 'scriptname.serial.lua' file created in TOOLS\ModScriptCheck folder
          shows exactly what AMUMSS sees internally of your script NMS_MOD_DEFINITION_CONTAINER.
      *** That file 'IMPROVED' format is a VERY good tool while developping your script! ***
  [*]IMPROVED: MapFileTree, options are:
      -MAPFILETREE LUA     --Create collapsable LUA MAPFILETREEs
      -MAPFILETREE LUAPLUS --(default) Create collapsable LUA MAPFILETREEs including </Property> lines as "<<<"
      -MAPFILETREE TXT     --Create TXT MAPFILETREEs
      -MAPFILETREE TXTPLUS --Create TXT MAPFILETREEs including </Property> lines as "<<<" 
  [*]IMPROVED: detection/reporting of INTEGER_TO_FLOAT conversion

  [*]CORRECTED: removed unnecessary NOTICE about multiple sections found when ["REPLACE_TYPE"] is in use
  [*]CORRECTED: false-positive detection of FLOAT that are in fact INTEGER
  [*]CORRECTED: using LINE_OFFSET, the wrong keyword line was used as the base line when PRECEDING_KEY_WORDS were used after SPECIAL_KEY_WORDS
  [*]CORRECTED: using ["ADD_OPTION"] = "ADDafterLINE", the found line was never used
  
