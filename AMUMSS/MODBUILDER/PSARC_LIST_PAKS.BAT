@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

if exist "Extras\lua_x64\bin\lua.exe" set "_mLUA=Extras\lua_x64\bin\lua.exe"

echo.^>^>^> Creating NMS PAK file lists. Please wait...

rem tell AMUMSS to refresh all scripts that need to be refreshed
if [%-CreateUsefulUtilityScripts%]==[Y] (
    echo.> "RefreshScripts.txt"
    if exist "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" (
        del /q "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" 1>NUL 2>NUL
    )
)

REM we are already in MODBUILDER
set "_pPAK_LIST=pak_list.txt"
set "_pPAK_Dir=pak_Dir.txt"

set "_pCurrentDirectory=!CD!"
set "_pMODBUILDERDirectory=!CD!"
REM echo. %_pCurrentDirectory%
REM echo. %_pMODBUILDERDirectory%

set /p _gNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt
set "_gNMS_PCBANKS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\PCBANKS"
REM echo. %_gNMS_PCBANKS_FOLDER%
REM pause

if exist "%_gNMS_PCBANKS_FOLDER%\NMSARC.5D36844D.pak" (
    set "_bOLDpaks=Y"
)

if exist "%_gNMS_PCBANKS_FOLDER%\NMSARC.B12267DC.pak" (
    set "_bOLDpaks=Y"
)

if exist "%_pPAK_LIST%" (
	del /f /q "%_pPAK_LIST%" 1>NUL 2>NUL
	del /f /q "%_pPAK_Dir%" 1>NUL 2>NUL
	del /f /q "PAK_LIST_CREATED.txt" 1>NUL 2>NUL
	del /f /q "HGPAKTool_error.txt" 1>NUL 2>NUL
)

if defined _bOLDpaks (
  echo.
  echo.   ==^> "%_gNMS_PCBANKS_FOLDER%"
  echo.  %_zBLACKonYELLOW% ==^>   contains OLDER type pak files that will not work.       %_zDEFAULT%
  echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
  echo.  %_zBLACKonYELLOW% PLEASE delete those old pak files and repair your game files. %_zDEFAULT%
  echo.  %_zBLACKonYELLOW%  AMUMSS will not be able to work ok until this is corrected.  %_zDEFAULT%
  echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
  pause
  goto :DONE
)

REM pushd "%_gNMS_PCBANKS_FOLDER%" 1>NUL 2>NUL
REM echo.^>^>^> Changed to !CD!

REM for %%I in ("*.pak.*") do (
  REM echo. %%~nxI
  REM REM "%_pMODBUILDERDirectory%\psarc.exe" list "%%~nxI" >> "%_pMODBUILDERDirectory%\%_pPAK_LIST%"
  REM "%_pMODBUILDERDirectory%\hgpaktool.exe" --upper -L -p -O "%_pMODBUILDERDirectory%\%_pPAK_LIST%" "%%~nxI"
  REM REM echo. >> "%_pMODBUILDERDirectory%\%_pPAK_LIST%"
REM )

"%_pMODBUILDERDirectory%\hgpaktool.exe" --upper -L -p -O "%_pMODBUILDERDirectory%\%_pPAK_LIST%" "%_gNMS_PCBANKS_FOLDER%"
if %ERRORLEVEL% EQU 0 goto :HGPAK_DONE
echo.>"HGPAKTool_error.txt"

:HGPAK_DONE
REM popd
REM Back in MODBUILDER

if not exist "%_pPAK_LIST%" (
  echo. "%_gNMS_PCBANKS_FOLDER%" does not contain any pak files.
  goto :DONE
)

REM to have a SMALL file with the same datetime that we can use later to check if we need to re-create pak_list.txt
echo.> "PAK_LIST_CREATED.txt"

echo.
echo.Created "TOOLS\NMS_FULL_%_pPAK_LIST%Pretty.lua"
echo.Created "TOOLS\NMS_%_pPAK_LIST%Pretty.lua"

Call :LuaEndedOkREMOVE
%_mLUA% FormatPAKlist.lua
Call :LuaEndedOk

echo.Created "TOOLS\NMS_%_pPAK_Dir%Pretty.lua"

REM copy them to AMUMSS TOOLS folder for user
move "%_pPAK_LIST%Pretty.lua" "..\TOOLS\NMS_%_pPAK_LIST%Pretty.lua" 1>NUL 2>NUL
REM xcopy /y /h /j "%_pPAK_LIST%Pretty.lua" "..\TOOLS\NMS_%_pPAK_LIST%Pretty.lua*" 1>NUL 2>NUL
REM del /f /q "%_pPAK_LIST%Pretty.lua" 1>NUL 2>NUL

REM move "%_pPAK_Dir%Pretty.lua" "..\TOOLS\NMS_%_pPAK_Dir%Pretty.lua" 1>NUL 2>NUL
xcopy /y /h /j "%_pPAK_Dir%Pretty.lua" "..\TOOLS\NMS_%_pPAK_Dir%Pretty.lua*" 1>NUL 2>NUL
REM del /f /q "%_pPAK_Dir%Pretty.lua" 1>NUL 2>NUL

rem Also copy the FULL NMS PCBANKS pak list
xcopy /y /h /j "Full_%_pPAK_LIST%" "..\TOOLS\NMS_FULL_%_pPAK_LIST%*" 1>NUL 2>NUL

rem make a smaller version of _pPAK_LIST for faster search
Call :LuaEndedOkREMOVE
%_mLUA% CleanPAKlist.lua
Call :LuaEndedOk

rem create list of top folders, save to MODBUILDER\NMSMainFolders.txt
Call :LuaEndedOkREMOVE
%_mLUA%  GetNMSMainFolders.lua
Call :LuaEndedOk

REM echo.
REM echo.^>^>^> Extracting MBIN(s) from PAK file(s), Please wait...
REM for %%G in ("..\Modscript\*.pak") do (
	REM echo.%%G
	REM "%_pCurrentDirectory%\psarc.exe" extract "%%G" --to="." -y 1>NUL 2>NUL
REM )

REM del /f /q "..\Modscript\MBIN_VersionList.txt" 1>NUL 2>NUL

REM rem to find version used to re=create an MBIN
REM for /R "..\Modscript\" %%G in ("*.MBIN") do (
	REM echo."%%G" >> "..\Modscript\MBIN_VersionList.txt"
	REM "%_pCurrentDirectory%\mbincompiler.exe" version -q "%%G" >> "..\Modscript\MBIN_VersionList.txt"
REM )

rem only when a NMS update occurred!
echo.     Cleaning cache...
CALL :Cleaning_TEMP
CALL :Cleaning_MapFileTrees
CALL :Cleaning_FileStructures
CALL :Cleaning_SavedSections

:DONE

REM echo.^>^>^> Changed to !CD!
echo off

REM pause
goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
rem --------------------------------------------

rem --------------------------------------------
:PROBLEM_FOLDER
    echo.
    echo.   - Make sure no file are in use by another app in that folder...
    echo.   - MAYBE another instance of AMUMSS is already open, close it...
	echo.   - Try to delete the folder yourself...
	echo.   - Close AMUMSS cmd window and re-try...
	pause
	EXIT

rem --------------------------------------------
:Cleaning_TEMP
	set "_bCount=0"
	:RETRY5
	if !_bCount! GTR 100 (
		echo.   xxxxx [WARNING] Problem cleaning folder 'MODBUILDER\_TEMP' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A "_bCount=_bCount+1"
	Del /f /q /s "_TEMP\*.*" 1>NUL 2>NUL
	if exist "_TEMP" (
		rd /s /q "_TEMP" 2>NUL
		goto :RETRY5
	)
	rem DO NOT create _TEMP
	EXIT /B
	
rem --------------------------------------------
:Cleaning_MapFileTrees
	Del /f /q "!CD!\TOOLS\MapFileTrees\*.*" 1>NUL 2>NUL
	ECHO. >ResetMapFileTreeDone.txt	
	EXIT /B
	
rem --------------------------------------------
:Cleaning_FileStructures
	rem was !CD!
	Del /f /q "..\TOOLS\FileStructures\*.*" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
:Cleaning_SavedSections
    Del /f /q "!CD!\TOOLS\SavedSections\*.*" 1>NUL 2>NUL
    EXIT /B
    
rem --------------------------------------------
:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.          From PSARC_LIST_PAKS.BAT>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an ERROR... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
