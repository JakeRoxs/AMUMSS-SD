@echo off
set "thisBAT=_Check_MODS_Status_run.bat"
title %thisBAT% %_CCver% --^> %CD%

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

echo.
echo.%_zBRIGHTGREEN%  %thisBAT% %_CCver%%_zDEFAULT%

MODBUILDER\%_mLUA% -e print(_VERSION)>temp.txt
set /p _bVersionLua=<temp.txt
echo.%_zBRIGHTGREEN%  %_bVersionLua% custom version with lfs%_zDEFAULT%
Del /f /q "temp.txt" 1>NUL 2>NUL

if %_bCurrentBuildDec% GEQ 22000 (
	set "_bWinVer=%_bWinVer:10=11%"
)

if %_bOS_bitness%==64 (
	echo.%_zBRIGHTGREEN%  %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
) else (
	echo.%_zBRIGHTGREEN%  %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
)
echo.%_zBRIGHTGREEN%  %DotNet5%%_zDEFAULT%
echo.%_zBRIGHTGREEN%  %DotNet6%%_zDEFAULT%
echo.%_zBRIGHTGREEN%  %DotNet8%%_zDEFAULT%

MODBUILDER\%_mLUA% .\MODBUILDER\GetVersionInfo.lua ".\\" ".\\MODBUILDER\\" "Y"
set /p _bNMS_VERSIONID=<"MODBUILDER\NMS_versionId.txt" 1>NUL 2>NUL

rem DO NOT REMOVE
set "_bB="

echo.
echo.^>^>^> %_bB% Starting in !CD!

rem we are using this now
Del /f /q "REPORT_MODS_Status.lua" 1>NUL 2>NUL

if exist "REPORT_MODS_Status.lua" (
	echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%       File "REPORT_MODS_Status.lua" cannot be opened          %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%     It may be that a previous cmd window is still open...     %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%           probably from running:                              %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%                      BUILDMOD / _%thisBAT%                   %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	echo.  %_zBLACKonYELLOW% Please terminate those previous cmd window^(s^) and re-try      %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	pause
	exit
)

rem **********************  start of NMS_FOLDER DISCOVERY section  *************************
rem try to find the NMS folder path
rem if the user gave a path, try to use it first
echo.
echo.^>^>^> %_bB% Checking Path to NMS_FOLDER...

rem *****************************************************
if not exist "CONFIG\NMS_FOLDER.txt" (
	rem we need to re-create it
	echo.
	REM echo.^>^>^>      Re-creating missing CONFIG\NMS_FOLDER.txt...
	REM copy /Y /B "MODBUILDER\NMS_FOLDER_BAK.txt" ".\CONFIG\NMS_FOLDER.txt" 1>NUL 2>NUL
	echo.   ===^>  PLEASE execute BUILDMOD.bat at least once before and re-run _%thisBAT%
	pause
	exit
)
rem *****************************************************

set /p _bNMS_FOLDER=<.\CONFIG\NMS_FOLDER.txt 1>NUL 2>NUL
echo !_bNMS_FOLDER!>test.txt
REM echo. A- [!_bNMS_FOLDER!]

set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"
REM echo. 0- [%_bNMS_PCBANKS_FOLDER%]

if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	echo. Current path does not work...
	for %%G in (1,2) do (
		if not defined _bFoundNMS (
			if %%G EQU 1 (
				rem NMS on Steam
				echo.   Trying NMS on Steam using registry
				set _bREGKEY="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 275850"
				set _bREGVAL="InstallLocation"
			)
			if %%G EQU 2 (
				rem NMS on GOG on 64bit
				echo.   Trying NMS on GOG on 64bit using registry
				set _bREGKEY="HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1446213994"
				set _bREGVAL="path"
			)
			
			rem for DEBUG
			REM REG QUERY !_bREGKEY! /v !_bREGVAL!
			set "_bvalue="
			FOR /F "usebackq skip=2 tokens=1,2*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
				set "_bvalue=%%C"
			)
			REM echo. E- !_bvalue!
			ECHO !_bvalue!>test.txt
			
			set /p _bNMS_FOLDER=<test.txt
			REM echo. B- [!_bNMS_FOLDER!]
			set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"
			REM echo. 1- [!_bNMS_PCBANKS_FOLDER!]
			if exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
				echo.
				echo.%_bB% Found Path to NMS_FOLDER...
				set "_bFoundNMS=y"
				goto :REG_EXPLORATION_DONE
			) else (
				echo.      not here...
			)
		)
	)
	echo.   Registry research done...
) else (
	set "_bFoundNMS=y"
)

:REG_EXPLORATION_DONE
echo.
if defined _bFoundNMS (
	copy /y "test.txt" "CONFIG\NMS_FOLDER.txt*" 1>NUL 2>NUL
) else (
	echo.^>^>^> %_bB% Still looking to locate path to NMS_FOLDER...
	echo.
	set "_bvalue="
	
	set _bREGKEY="HKLM\SOFTWARE\WOW6432Node\Valve\Steam"
	set _bREGVAL="InstallPath"
	FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
		if [%%B]==[] (
			set "_bvalue=%%A"
		) else (
			set "_bvalue=%%A %%B"
		)
	)
	ECHO !_bvalue!>test.txt
	set /p _bNMS_FOLDER=<test.txt
	set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"
	REM echo. 1- [!_bNMS_PCBANKS_FOLDER!]
	if exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
		echo.
		echo.%_bB% Found Path to NMS_FOLDER...
		copy /y "test.txt" "CONFIG\NMS_FOLDER.txt*" 1>NUL 2>NUL
	) else (
		rem then NMS could be in a Steam Library folder
		ECHO !_bvalue!>test.txt
		echo.   Looking for Libraries in: [!_bvalue!]
		echo.
		
		Call :LuaEndedOkREMOVE
		set "location=bz15"
		MODBUILDER\%_mLUA% MODBUILDER\GetNMSFolder.lua "!_bvalue!" ".\\MODBUILDER\\"
		Call :LuaEndedOk
	)	
)

set "_bREGKEY="
set "_bREGVAL="
set "_bvalue="
set "_bFoundNMS="

set /p _bNMS_FOLDER=<CONFIG\NMS_FOLDER.txt
set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"

REM look for GamePass
if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	echo.   Looking for GAMEPASS No Man's Sky folder
	MODBUILDER\%_mLUA% .\MODBUILDER\GetGamePassPath.lua
)

set /p _bNMS_FOLDER=<CONFIG\NMS_FOLDER.txt
set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"

if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	echo.********************* PLEASE correct your path in CONFIG\NMS_FOLDER.txt, NMS game files not found ********************
	echo. Bad Path to: ["%_bNMS_PCBANKS_FOLDER%BankSignatures.bin"]
	echo. Found this PATH in [CONFIG\NMS_FOLDER.txt] "%_bNMS_FOLDER%"
	echo.%_zBRIGHTRED% ^>^>^> Your PATH in [CONFIG\NMS_FOLDER.txt] must be pointing to the folder containing 'GAMEDATA' %_zDEFAULT%
	echo.***** Terminating batch until corrected...
	pause
	exit
) else (
	echo. %_zBLACKonYELLOW% Path to NMS_FOLDER is ^>^>^>%_zDEFAULT%%_zWHITEonDARKCYAN% GOOD %_zDEFAULT%%_zBLACKonYELLOW%^<^<^< game files found %_zDEFAULT%
)
cd /D "%~dp0"

echo.
echo.^>^>^> %_bB% Updating CONFIG\NMS_FOLDER.txt to "%_bNMS_FOLDER%"
copy /y "CONFIG\NMS_FOLDER.txt" "MODBUILDER\NMS_FOLDER_BAK.txt*" >NUL
Del /f /q "test.txt" 1>NUL 2>NUL
rem **********************  end of NMS_FOLDER DISCOVERY section  *************************

REM rem *********************  NOW IN MODBUILDER  *******************
REM cd MODBUILDER

if exist "MBINCompiler.exe" (
    Del /f /q "MBINCompilerVersion.txt" 1>NUL 2>NUL
    MBINCompiler.exe version -q >>MBINCompilerVersion.txt
    set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt

    if exist "MBINCompiler.public.exe" (
        Del /f /q "MBINCompilerPublicVersion.txt" 1>NUL 2>NUL
        MBINCompiler.public.exe version -q >>MBINCompilerPublicVersion.txt
        set /p _bMBINCompilerPublicVersion=<MBINCompilerPublicVersion.txt
    )
    if exist "MBINCompiler.latest.exe" (
        Del /f /q "MBINCompilerLatestVersion.txt" 1>NUL 2>NUL
        MBINCompiler.latest.exe version -q >>MBINCompilerLatestVersion.txt
        set /p _bMBINCompilerLatestVersion=<MBINCompilerLatestVersion.txt
    )
)

if not exist "CustomMBINCompiler.txt" (    
    echo.
    echo.^>^>^> MBINCompiler 'latest' version: %_zBRIGHTGREEN%!_bMBINCompilerLatestVersion!%_zDEFAULT%
    echo.^>^>^> MBINCompiler 'public' version: %_zBRIGHTGREEN%!_bMBINCompilerPublicVersion!%_zDEFAULT%
)

echo.
if not defined _bStartTime (
	Call :LuaEndedOkREMOVE
	set "location=bz8"
	SET "_bStartTime=Y"
	%_mLUA% StartTime_MODS_Status.lua "..\\" "" "%thisBAT%"
	Call :LuaEndedOk
)

			echo.
			echo.^>^>^> Doing MODS Status Detection in GAMADATA\MODS, BE PATIENT...
			
			Call :LuaEndedOkREMOVE
			rem %_mLUA% "Get_MODS_List.lua" "UpdateNMS" | (tee.exe -a ..\log.lua)
			%_mLUA% "Get_MODS_List.lua" "UpdateNMS"
			Call :LuaEndedOk

			Call :LuaEndedOkREMOVE
			set "location=bz5_CheckMODS.lua"
			rem %_mLUA% "CheckMODS.lua" | (tee.exe -a ..\log.lua)
			%_mLUA% "CheckMODS.lua"
			Call :LuaEndedOk

			rem ******   NOW IN AMUMSS folder   ********
			cd ..


REM get time to process
if defined _bStartTime (
	Call :LuaEndedOkREMOVE
	set "location=bz3"
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\EndTime_MODS_Status.lua" ".\\" ".\\MODBUILDER\\"
	Call :LuaEndedOk

	Call :LuaEndedOkREMOVE
	set "location=bz2"
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\DiffTime_MODS_Status.lua" ".\\" ".\\MODBUILDER\\" "(%thisBAT% %_CCver%)"
	Call :LuaEndedOk
)

goto :eof


rem *****************************************************************************************
rem               --------------------- WE ARE DONE ---------------------
rem *****************************************************************************************

rem --------------------------------------------
rem subroutine section starts below
	
rem --------------------------------------------
:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.          From bzrun.BAT %location%>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.    [BUG] lua.exe generated an [ERROR]... Please report MODS_Status.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
