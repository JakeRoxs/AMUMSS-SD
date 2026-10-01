@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem -------- We are in MODBUILDER  -------------
set "_pModScript_pakContent_list=ModScript_pakContent_list.txt"
set "_pModScript_pak_list=ModScript_pak_list.txt"
set "_pMODBUILDERDirectory=!CD!"

rem -------- We are in Modscript  -------------
cd ..\Modscript
REM echo.^>^>^> Changed to !CD!

echo.^>^>^> Getting list of files from ModScript PAK file(s), please wait...

echo|set /p="FROM ModScript">> "%_pMODBUILDERDirectory%\%_pModScript_pakContent_list%"
echo. >> "%_pMODBUILDERDirectory%\%_pModScript_pakContent_list%"

for %%I in ("*.pak.*") do (
	set "process="
	set "name=%%I"
	REM echo.  name = !name!
	set "_dummy=!name:.pak.=!"
	REM echo. dummy = !_dummy!
	if not [!_dummy!]==[!name!] (
		REM echo. a .pak. extension
		set "process=Y"
	) else (
		rem echo. NOT a .pak. extension
		set "ext=%%~xI"
		rem echo.   ext = !ext!
		set "last4=!name:~-4!"
		rem echo. last4 = !last4!
		if not [!ext!]==[!last4!] (
			rem echo.   EXT are NOT EQUAL
		) else (
			rem echo.   EXT are EQUAL
			set "process=Y"
		)		
	)
	
	if defined process (
		echo.  - %%~nxI
		
		echo...\ModScript\%%~nxI>> "%_pMODBUILDERDirectory%\%_pModScript_pak_list%"
		
		echo|set /p="[INFO]   - %%~nxI">>"%_bMASTER_FOLDER_PATH%REPORT.lua" & echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		"%_pMODBUILDERDirectory%\psarc.exe" list "..\ModScript\%%~nxI" >> "%_pMODBUILDERDirectory%\%_pModScript_pakContent_list%"
		echo. >> "%_pMODBUILDERDirectory%\%_pModScript_pakContent_list%"
	)
)

REM if not exist "%_pMODBUILDERDirectory%\%_pModScript_pakContent_list%" (
  REM echo. "!CD!" does not contain any pak files.
  REM goto :DONE
REM )

REM :DONE
rem -------- We are in MODBUILDER  -------------
cd ..\MODBUILDER
REM echo.^>^>^> Changed to !CD!

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
rem --------------------------------------------
:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.          From PSARC_LIST_ModScriptPAKS.BAT>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an ERROR... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua" & echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	)
	EXIT /B
	
rem --------------------------------------------

ENDLOCAL
