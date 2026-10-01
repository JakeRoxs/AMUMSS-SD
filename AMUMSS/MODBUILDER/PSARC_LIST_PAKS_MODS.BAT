@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem -------- We are in MODBUILDER  -------------
REM echo.^>^>^> Changed to !CD!
rem rem echo. THIS FROM PSARC_LIST_PAKS_MODS.BAT: %_bMASTER_FOLDER_PATH%
set "_mLUA=Extras\lua_x64\bin\lua.exe"

REM set "_pMODS_PAK_LIST=MODS_pak_list.txt"
REM set "_pMODBUILDERDirectory=!CD!"

REM set /p _gNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt
REM set "_gNMS_MODS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\MODS"

Call :LuaEndedOkREMOVE
set "location=Get_MODS_List.lua"
%_mLUA% Get_MODS_List.lua
Call :LuaEndedOk

REM pushd "%_gNMS_MODS_FOLDER%" 1>NUL 2>NUL
REM echo.^>^>^> Changed to !CD!

REM echo.
REM echo.^>^>^> Getting list of files from NMS MODS folder(s)...

REM echo|set /p="FROM MODS">> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
REM echo. >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"

REM rem for %%I in ("*.pak.*") do (
REM for /D %%I in (*) do (
    REM echo.  - %%~nxI
    REM echo. >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
    REM echo.Listing %%~nxI>> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
    REM rem echo.    files in %%~nxI:
    REM pushd "%_gNMS_MODS_FOLDER%\%%~nxI\"
    REM for /R %%J in (*) do (
        REM echo.    - %%~nxI\%%~nxJ
        REM echo.%%~nxJ>> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
    REM )
    REM popd
    REM REM "%_pMODBUILDERDirectory%\psarc.exe" list "%_gNMS_MODS_FOLDER%\%%~nxI" >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
    REM rem "%_pMODBUILDERDirectory%\psarc.exe" list "%%~nxI" >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
    REM rem echo. >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
REM )

REM popd
REM echo.^>^>^> Changed to !CD!

REM rem Get list of lua scripts from %_pMODS_PAK_LIST% and create ScriptList.xml
REM %_mLUA% GetListOfScriptsInPaks.lua

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
rem --------------------------------------------
:LuaEndedOk
    rem echo. THIS FROM PSARC_LIST_PAKS_MODS.BAT: %_bMASTER_FOLDER_PATH%
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.          From PSARC_LIST_PAKS_MODS.BAT>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an [ERROR]... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
    Del /f /q "%_bMASTER_FOLDER_PATH%LuaEndedOK.txt" 1>NUL 2>NUL
    EXIT /B
    
