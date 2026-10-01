********************************************************************************
   (default) are processed in BUILDMOD.bat, PLEASE DO NOT CHANGE 'BUILDMOD.bat'

   >>> MAKE ALL YOUR OPTION PREFERENCES KNOWN BY MODIFYING 'BUILDMOD_AUTO.bat' <<<
   
   The (default) OPTIONS are:
                -AutoUpdateAMUMSS Y
				-AutoUpdateMBinCompiler Y
				-BackupReports 10
				-BackupType PAK
                -CheckForModConflicts M
                -CLEANLOG Y
                -CombineModPak ASK
                -CopyToGamefolder ASK
				-CreateUsefulUtilityScripts N
                -DEV_MODE ASK
				-EXPORTED Y
				-EXT_FUNC_Helper N
                -GUIF_AllowRequests Y
				-GUIF_DelayMult 1.0
				-FileStructureLevel 1
                -GameVersion ASK
                -IncludeLuaScriptInPak Y
                -IncludeTagsInEXML_MXML Y
                -IncrementalBuilds 3
                -MAPFILETREE LUA
				-MODSfolderNameScript N
				-NMSreStart N
                -ReCreateMapFileTree N
                -RecreatePAKList N
                -SerializeScript N
                -SHOWEXTRASECTIONS N
                -SHOWOPTIONS N
                -SHOWSECTIONS N
				-SHOWSimpleContainer N
                -SOUND Y
				-TABtoSPACES 2
				-TestScript Y
                -UseColors Y
                -UseColorConfig Y
                -UseColorConfigFile AMUMSS_colors.cfg
                -UseExtraFilesInPAK ASK
                -UseLastCompiler Y
                -UseLuaScriptInPak ASK
				-VerboseFinalREPORT Y
                
examples: notice the "-" at the beginning of the option word, one space and the option value
          copy/paste is the best!

this would use all the (default) OPTIONS like double-clicking 'BUILDMOD.bat'

TO ADD a new OPTION not in your 'BUILDMOD_AUTO.bat':
    just add aline like
      "set _O=%_O%      -DEV_MODE ASK" without the ""
    to the other OPTIONS, order is not important
********************************************************************************

>>>>>>>>>>>>>>>  Below are the OPTION definitions:  <<<<<<<<<<<<<<<<<<

-AutoUpdateAMUMSS Y -- (default) Auto-update AMUMSS
-AutoUpdateAMUMSS N -- Ask to update AMUMSS

-AutoUpdateMBinCompiler ASK -- ask if should update MBINCompiler.exe version if a new version exist
-AutoUpdateMBinCompiler Y   -- (default) update MBINCompiler.exe in MODBUILDER if a newer version exist, no asking
-AutoUpdateMBinCompiler N   -- never update MBINCompiler.exe

-BackupReports 10   -- number of BackupReports to keep (default is 10 each of log.lua and REPORT.lua)
					-- 1 or less disables BackupReports (but will always keep atleast the last ones)

-- Usually, by size decreasing: NONE, .zip, .7z, .pak
-BackupType NONE -- Backups of a mod are in a folder like in MODS
-BackupType 7z   -- Backups of a mod will be compressed as .7z
-BackupType zip  -- Backups of a mod will be compressed as .zip
-BackupType pak  -- (default) Backups of a mod will be compressed as a psarc.exe/PSarcTool.exe .pak
					
-CheckForModConflicts ASK
-CheckForModConflicts Y            -- Check mod conflicts in both ModScript and MODS folder
-CheckForModConflicts SCRIPTS or S -- Check mod conflicts between ModScript files only
-CheckForModConflicts MODS or M    -- (default) Check mod conflicts in MODS folder only
-CheckForModConflicts N            -- Never check for conflicts

-CLEANLOG Y -- (default) removes escape sequences from log.lua
-CLEANLOG N

-- OBSOLETE/DEPRICATED
-CombinedModType ASK -- (default)
OBSOLETE -CombinedModType 1   -- GENERIC COMBINED MOD PAK + current DATE-TIME suffix
-CombinedModType 2   -- DISTINCT COMBINED MOD PAK with a NUMERIC suffix
-CombinedModType 3   -- COMPOSITE-NAME COMBINED MOD PAK like Mod1+Mod2+Mod3.pak

-CombineModPak ASK -- (default)
-CombineModPak Y   -- create a Combined MODs (all scripts in ModScripts including sub-folders)
-CombineModPak N   -- create INDIVIDUAL MODs (except where ___COMBINE.txt exist in sub-folders)

-- OBSOLETE/DEPRICATED
               -- NOTE: Turning OFF compression will increase pak size considerably
-CompressPAK Y -- (default) Created PAKs are compressed regardless of script 'COMPRESS_PAK'
-CompressPAK N -- Created PAKs are NOT compressed regardless of script 'COMPRESS_PAK'
-CompressPAK S -- allow Script's 'COMPRESS_PAK' command to dictate compression state

-CopyToGamefolder ASK       -- (default) Ask which option to use (NONE, SOME, ALL)
-CopyToGamefolder NONE or N -- Do not copy any created mods to the game folder
-CopyToGamefolder SOME      -- Ask which created mods to copy to the game folder
-CopyToGamefolder ALL or Y  -- Copy all created mods to the game folder

-CreateUsefulUtilityScripts N -- (default) DO NOT Re-Create TOOLS\Useful Utility Scripts\*.lua after an update
-CreateUsefulUtilityScripts Y -- Re-Create TOOLS\Useful Utility Scripts\*.lua after an update
                              -- After setting to "Y", delete 'MODBUILDER\pak_list.txt' to force a reset.

              -- NOTE: In any DEV_MODE: ALL information is still in Report.lua
-DEV_MODE ASK -- (default)
-DEV_MODE F   -- FULL mode: instruct AMUMSS to generate ALL information
                          (slowest, with full feedback to modder)
-DEV_MODE D   -- DEV  mode: instruct AMUMSS to generate ALL 'helper' files
                          most information is still in the Report.lua file
                          (medium, but adequate information to modder in the cmd window)
-DEV_MODE L   -- LEAN mode: AMUMSS only generates files necessary to produce the mods
                          most information is still in the Report.lua file
                          (fastest, much less information to user in the cmd window)

-EXPORTED Y -- activates the EXPORTED feature of NMS
-EXPORTED N -- (default) does not activate the EXPORTED feature of NMS

-EXT_FUNC_Helper Y   -- unpak/decompile resulting pak for easier EXML comparison
-EXT_FUNC_Helper N   -- (default) do nothing

-GUIF_AllowRequests ASK
-GUIF_AllowRequests Y   -- (default) Globally, allow script configuration
-GUIF_AllowRequests N   -- Globally, do not allow script configuration

-GUIF_DelayMult 1.0 -- (default) Globally multiply all GUIF script delays by this value

-FileStructureLevel 1 -- (default) creates 'high level basic structure' of EXML files in TOOL\FileStructures folder
-FileStructureLevel 2 -- adds related information to the 'high level basic structure'
-FileStructureLevel 3 -- adds ALL information from the EXML file

-GameVersion ASK -- (default)
-GameVersion E   --  experimental (The beta versions, only available with Steam/GoG)
-GameVersion P   --  public (The normal game release from Steam/GoG and mostly all other platforms)

-IncludeLuaScriptInPak ASK
-IncludeLuaScriptInPak Y -- (default) Include the lua script in the mod PAK
-IncludeLuaScriptInPak N -- Do not include the lua script in the mod PAK

-IncludeTagsInEXML_MXML Y -- (default) # tags/EOL comments are written to EXMLs and MXMLs
-IncludeTagsInEXML_MXML N -- # tags/EOL comments are NOT written to EXMLs and MXMLs

-IncrementalBuilds 3  -- number of IncrementalBuilds to keep (default is 3)

-- OBSOLETE/DEPRICATED
-IndividualModPakType ASK
-IndividualModPakType PLAIN or P    -- (default) Name of Mod pak is MOD_FILENAME
-IndividualModPakType DATETIME or D -- Name of Mod pak is MOD_FILENAME + current DATE-TIME suffix

-MAPFILETREE LUA     -- Create collapsable LUA MAPFILETREEs
-MAPFILETREE LUAPLUS -- (default) Create collapsable LUA MAPFILETREEs including </Property> lines as "<<<"
-MAPFILETREE TXT     -- Create TXT MAPFILETREEs
-MAPFILETREE TXTPLUS -- Create TXT MAPFILETREEs including </Property> lines as "<<<" 

-- OBSOLETE/DEPRICATED
-MAPFILETREEFORCE Y -- Force creation of MAPFILETREE files in main thread
-MAPFILETREEFORCE N -- (default) MAPFILETREE files are created by 2nd thread

-- OBSOLETE/DEPRICATED
-MODDER_HELPER Y -- (default) the TOOLS\MODDER_Helper folder is updated
-MODDER_HELPER N -- the TOOLS\MODDER_Helper folder is NOT updated

-MODSfolderNameScript Y -- The name of the MODS sub-folder will be the name of the individual script
-MODSfolderNameScript N -- (default) The name of the MODS sub-folder will be MOD_FILENAME of the individual script

-NMSreStart Y -- AMUMSS will ask if you want to start/restart NMS after processing
-NMSreStart N -- (default) AMUMSS will not start/restart NMS after processing

-ReCreateMapFileTree ASK
-ReCreateMapFileTree Y -- Force re-creation of the MapFileTree files (should not be required, only use in extreme cases)
-ReCreateMapFileTree N -- (default) Do not re-create MapFileTree files if they already exist and are newer than the MBIN file
-ReCreateMapFileTree X -- NEVER create MapFileTree files (only use if you don't use MapFileTree files)

-RecreatePAKList ASK
-RecreatePAKList Y -- forced to re-create (should not be required, only use in debugging)
-RecreatePAKList N -- (default) re-create only when needed based on AMUMSS assessment

-SerializeScript Y -- Creates a NameOfScript_serial.lua version of the script in main folder
-SerializeScript N -- (default) Does not creates a NameOfScript_serial.lua version of the script in main folder

-SHOWEXTRASECTIONS Y -- To show all info on sections
-SHOWEXTRASECTIONS N -- (default) Do not show all info on sections

-SHOWOPTIONS Y -- Show OPTIONS sent to BUILDMOD.bat
-SHOWOPTIONS N -- (default) Do not show OPTIONS sent to BUILDMOD.bat

-SHOWSECTIONS Y -- (default) Show found section information
-SHOWSECTIONS N -- Do not show found section information

-SHOWSimpleContainer Y -- Show a simple representation of loaded scripts for debugging
-SHOWSimpleContainer N -- (default) Do not show

-SOUND Y -- (default)
-SOUND N

-TABtoSPACES 2 -- (default = 2) converts TAB to SPACES in MXML files

-TestScript Y -- (default) Do ALL checks of the script prior to loading it
-TestScript N -- Skip ALL checks of the script

-UseColors Y -- (default) Use colors in cmd/terminal window
-UseColors N -- DO NOT use colors in cmd/terminal window

-UseColorConfig Y -- (default) update colors in cmd window using the -UseColorConfigFile
-UseColorConfig N -- Do NOT update colors (keep using what AMUMSS provides)

-UseColorConfigFile -- the name of the CONFIG\???.cfg file to use
                       Defaults to AMUMSS_colors.cfg

       -- NOTE: This Option does not affect MEFTI folder content which is always included
-UseExtraFilesInPAK ASK -- (default)
-UseExtraFilesInPAK Y   -- Include the files in ModScript\GlobalMEFTI folder in the created mod
-UseExtraFilesInPAK N   -- Do not include the files in ModScript\GlobalMEFTI folder in the created mod

-UseLastCompiler Y -- (default) try to use the last compiler.exe that was able to decompile a file
-UseLastCompiler N -- When unpacking to TOOLS\UNPACKED_DECOMPILED_PAKs a pak in Modscript
                      AMUMSS will NOT use the last compiler.exe that was able to decompile a file,
                      but will try to find a better compiler.exe for the next file.
                      IT WILL TAKE MORE TIME TO UNPACK THE PAK FILE, BUT the decompiling may be MORE ACCURATE.

-UseLuaScriptInPak ASK -- (default) 
-UseLuaScriptInPak Y   -- Use the lua script included in the PAK to re-build the mod
-UseLuaScriptInPak N   -- Do not use the lua script included in the PAK to re-build the mod

-VerboseFinalREPORT Y -- (default) in REPORT, shows extra information for ERROR/WARNING/NOTICE
-VerboseFinalREPORT Y -- do not show extra information for ERROR/WARNING/NOTICE
