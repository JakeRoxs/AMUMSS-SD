@echo off
rem *****************  we are in MODBUILDER  ***********
REM echo.^>^>^>     In MBINCompilerDownloader.bat
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem used only if in standalone mode for debug
if not defined _mLUA (set "_mLUA=Extras\lua_x64\bin\lua.exe")

rem *****************  we are in MBINCompilerDownloader  ***********
cd MBINCompilerDownloader

:TRYAGAIN
set /A "retry_count+=1"
if %retry_count% GTR 2 (
	echo.
	echo.%_zBRIGHTRED% ====================================================================================%_zDEFAULT%
	echo. %_zINVERSE% [WARNING] Problem fetching from Web, using your current version if possible      %_zDEFAULT%
	echo.%_zBRIGHTRED% ====================================================================================%_zDEFAULT%
	echo|set /p=".   [WARNING] Problem fetching MBINCompiler.exe from Web, using your current version if possible">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"
	goto :ENDING
)

set "_curlpath="
if exist %SYSTEMROOT%\system32\curl.exe (
	REM echo.       **** windows curl.exe exist ****
	set "_curlExist=*"
	set "_curlpath=%SYSTEMROOT%\system32\"
)

Del /f /q "RAW.txt" 1>NUL 2>NUL

REM @echo on
REM %_curlpath%curl.exe --help all
REM pause
rem  --ssl-no-revoke --connect-timeout 30
rem %_curlpath%curl.exe -s -H "Accept: application/vnd.github+json" -o RAW.txt "https://api.github.com/repos/monkeyman192/MBINCompiler/releases"

        %_curlpath%curl.exe -s -H "Accept: application/vnd.github.raw+json" "https://api.github.com/repos/monkeyman192/MBINCompiler/releases" -o RAW.txt 

REM pause
..\%_mLUA% ExtractLink.lua
rem pause

set /p _URL_1=<temp1.txt
set /p _URL_2=<temp2.txt

if exist "URLPrevious.txt" (
	set /p _URLPrevious=<URLPrevious.txt
	REM echo. [!_URLPrevious!]
)

if exist "URL_2_Previous.txt" (
	set /p _URL_2_Previous=<URL_2_Previous.txt
	REM echo. [!_URL_2_Previous!]
)

if not exist "..\MBINCompiler.exe" (
	rem force download
	set "_URLPrevious="
	set "_URL_2_Previous="
)

set "_Check=Y"
if "[%_URL_1%]"=="[%_URLPrevious%]" (
	if "[%_URL_2%]"=="[%_URL_2_Previous%]" (
		set "_Check="
		echo.  %H._zBRIGHTGREEN% ==^> %_curlExist% MBINCompiler is up-to-date!%_zDEFAULT%
		rem ********************  we are in MODBUILDER  *********************
		cd ..
	)
)

if defined _Check (
	echo.
	echo.^>^>^> %_curlExist%Getting latest MBINCompiler.exe from Web...
	%_curlpath%curl.exe -LO --ssl-no-revoke --connect-timeout 30 %_URL_1%
	
	if exist "MBINCompiler.exe" (
		echo|set /p="%_URL_1%">URLPrevious.txt
		xcopy /y /h "MBINCompiler.exe" "..\MBINCompiler.latest.exe*" 1>nul 2>nul
		xcopy /y /h "MBINCompiler.exe" "..\MBINCompiler.exe*" 1>nul 2>nul
		REM in case this is also a 'release' for public
		xcopy /y /h "MBINCompiler.exe" "..\MBINCompiler.public.exe*" 1>nul 2>nul
		
		rem del downloaded file
		Del /f /q /s "MBINCompiler.exe" 1>NUL 2>NUL
		
		rem ********************  we are in MODBUILDER  *********************
		cd ..
		
		rem tell AMUMSS to refresh all scripts that need to be refreshed
        if [%-CreateUsefulUtilityScripts%]==[Y] (
            echo.> "RefreshScripts.txt"
            if exist "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" (
                del /q "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" 1>NUL 2>NUL
            )
        )
		
		echo.     Cleaning cache...
		CALL :Cleaning_TEMP
		CALL :Cleaning_MapFileTrees
		CALL :Cleaning_FileStructures
		CALL :Cleaning_SavedSections
		
		Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
		MBINCompiler.latest.exe version -q >>MBINCompilerVersion.txt
		set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
		Del /f /q /s "MBINCompiler.log" 1>NUL 2>NUL
		
		echo.
		echo.^>^>^> Added %H._zBRIGHTGREEN%MBINCompiler.!_bMBINCompilerVersion!.exe%_zDEFAULT% to Extras\MBINCompiler_OldVersions folder...
		echo.
		rem was !CD!
		xcopy /y /h "MBINCompiler.latest.exe" ".\Extras\MBINCompiler_OldVersions\MBINCompiler.!_bMBINCompilerVersion!.exe*" 1>nul 2>nul

		rem *****************  we are in MBINCompilerDownloader  ***********
		cd MBINCompilerDownloader
		
		echo.^>^>^> Getting latest libMBIN.dll from Web...

	REM ************ this is for .net4 version
	REM _libMBIN_URL=%_URL_1:MBINCompiler.exe=libMBIN-dotnet4.dll%
	
		set "_libMBIN_URL=%_URL_1:MBINCompiler.exe=libMBIN.dll%"
		REM echo.!_libMBIN_URL!
		%_curlpath%curl.exe -LO --ssl-no-revoke --connect-timeout 30 !_libMBIN_URL!

	rem Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
	rem ren libMBIN-dotnet4.dll libMBIN.dll 1>nul 2>nul
	
		rem copy to MODBUILDER
		xcopy /y /h "libMBIN.dll" "..\libMBIN.latest.dll*" 1>nul 2>nul

		REM in case this is a 'release'
		rem copy to MODBUILDER
		xcopy /y /h "libMBIN.dll" "..\libMBIN.public.dll*" 1>nul 2>nul

rem libMBIN.dll is created by NMWPE from libMBIN.latest.dll
		rem copy to AMUMSS main
		REM xcopy /y /h "libMBIN.dll" "..\..\" 1>nul 2>nul

rem 'previous' UNTIL NMSPE is updated

		REM in case this is a 'release'
		rem copy to AMUMSS main
		REM xcopy /y /h "libMBIN.dll" "..\..\libMBIN.previous.dll*" 1>nul 2>nul

		rem del downloaded file
		Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL

		REM *************  get public release
		set /p _URL_2=<temp2.txt
		REM echo !_URL_2!

		if NOT [%_URL_1%]==[!_URL_2!] (		
			%_curlpath%curl.exe -LO --ssl-no-revoke --connect-timeout 30 !_URL_2!
			
			if exist "MBINCompiler.exe" (
				echo|set /p="%_URL_2%">URL_2_Previous.txt
				
				Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
				MBINCompiler.exe version -q >>MBINCompilerVersion.txt
				set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
				Del /f /q /s "MBINCompiler.log" 1>NUL 2>NUL

				echo.
				echo.^>^>^> Added %H._zBRIGHTGREEN%MBINCompiler.!_bMBINCompilerVersion!.exe%_zDEFAULT% to Extras\MBINCompiler_OldVersions folder...
				echo.
				xcopy /y /h "MBINCompiler.exe" "..\Extras\MBINCompiler_OldVersions\MBINCompiler.!_bMBINCompilerVersion!.exe*" 1>nul 2>nul			
				
				rem copy to MODBUILDER
				xcopy /y /h "MBINCompiler.exe" "..\MBINCompiler.public.exe*" 1>nul 2>nul

				rem del downloaded file
				Del /f /q /s "MBINCompiler.exe" 1>NUL 2>NUL

				echo.^>^>^> Getting latest libMBIN.dll from Web...

		REM ********* this is for .net4 version
		REM set _libMBIN_URL=!_URL_2:MBINCompiler.exe=libMBIN-dotnet4.dll!
		
		REM ********* this is for .net6 version
		REM set _libMBIN_URL=!_URL_2:MBINCompiler.exe=libMBIN-dotnet6.dll!
		
				REM ********* this is for standard version
				set "_libMBIN_URL=!_URL_2:MBINCompiler.exe=libMBIN.dll!"
				
				REM echo.!_libMBIN_URL!
				%_curlpath%curl.exe -LO --ssl-no-revoke --connect-timeout 30 !_libMBIN_URL!

		REM ********* this is for .net4 version
		REM Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
		REM ren libMBIN-dotnet4.dll libMBIN.dll 1>nul 2>nul
		
		REM ********* this is for .net6 version
		REM Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
		REM ren libMBIN-dotnet6.dll libMBIN.dll 1>nul 2>nul
		
				rem copy to MODBUILDER
				xcopy /y /h "libMBIN.dll" "..\libMBIN.public.dll*" 1>nul 2>nul
				
				rem del downloaded file
				Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
			)
		) else (
			echo|set /p="%_URL_2%">URL_2_Previous.txt
		)
		
		rem ********************  we are in MODBUILDER  *********************
		cd ..
	
	) else (
		echo. %_zBLACKonYELLOW%^>^>^> Could not download current version of MBINCompiler.exe%_zDEFAULT%
		echo. %_zBLACKonYELLOW%^>^>^> Check your internet connection, retrying...%_zDEFAULT%
		ping -n 5 127.0.0.1>nul
		goto :TRYAGAIN
	)
)

:ENDING
rem ********************  we are in MODBUILDER  *********************
@echo off

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
	rem was !CD!
	Del /f /q "..\TOOLS\MapFileTrees\*.*" 1>NUL 2>NUL
	ECHO. >ResetMapFileTreeDone.txt	
	EXIT /B
	
rem --------------------------------------------
:Cleaning_FileStructures
	rem was !CD!
	Del /f /q "..\TOOLS\FileStructures\*.*" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
:Cleaning_SavedSections
    Del /f /q "..\TOOLS\SavedSections\*.*" 1>NUL 2>NUL
    EXIT /B
    
rem --------------------------------------------
	
