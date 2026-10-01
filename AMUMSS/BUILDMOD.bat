@echo off
cd /D "%~dp0"

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

set "_BMver=v2.2.0"
set "_mOK=Y"
title BUILDMOD %_BMver%  --^> %~dp0

rem TO DEBUG when a user says the cmd window closes right away...
REM set "_DEBUG=Y"
REM set "bypass=Y"

if defined _DEBUG (
	echo.
	echo.!path!
	echo.
	pause
)

set "GoodSystemPath=N"
set "sys32=Y"
set "win=Y"
set "wbem=Y"
set "powershell=Y"

REM C:\WINDOWS\system32
REM C:\WINDOWS
REM C:\WINDOWS\System32\Wbem
REM C:\WINDOWS\System32\WindowsPowerShell\v1.0\
REM C:\WINDOWS\System32\OpenSSH\

if ["%path:C:\WINDOWS;=%"]==["%path%"] set win=N
if ["%path:C:\WINDOWS\system32;=%"]==["%path%"] set sys32=N
if ["%path:C:\WINDOWS\system32\Wbem;=%"]==["%path%"] set wbem=N
if ["%path:C:\WINDOWS\system32\WindowsPowerShell\v1.0\;=%"]==["%path%"] set powershell=N

if [%win%]==[Y] (
	if [%sys32%]==[Y] (
		if [%wbem%]==[Y] (
			if [%powershell%]==[Y] (
				set GoodSystemPath=Y
			)
		)
	)
)
if defined _DEBUG (
	echo. A: Testing C:\WINDOWS: win=%win% sys32=%sys32% wbem=%wbem% powershell=%powershell%
	pause
)

if [%GoodSystemPath%]==[N] (
	rem for the very RARE case that 'Windows' is NOT installed in C:\WINDOWS
	if [%win%]==[N] (
		if not ["%path:SystemRoot%%;=%"]==["%path%"] set win=Y
	)
	if [%sys32%]==[N] (
		if not ["%path:SystemRoot%%\system32;=%"]==["%path%"] set sys32=Y
	)
	if [%wbem%]==[N] (
		if not ["%path:SystemRoot%%\system32\Wbem;=%"]==["%path%"] set wbem=Y
	)
	if [%powershell%]==[N] (
		if not ["%path:SystemRoot%%\system32\WindowsPowerShell\v1.0\;=%"]==["%path%"] set powershell=Y
	)
	
	if [!win!]==[Y] (
		if [!sys32!]==[Y] (
			if [!wbem!]==[Y] (
				if [!powershell!]==[Y] (
					set GoodSystemPath=Y
				)
			)
		)
	)
	if defined _DEBUG (
		echo. B: Testing SystemRoot: win=!win! sys32=!sys32! wbem=!wbem! powershell=!powershell!
		pause
	)
)

set "pathNoSpaces=%path: =%"
if not ["%pathNoSpaces:WindowsResourceKits\Tools\;=%"]==["%pathNoSpaces%"] (
	echo. 
	echo. *****************************************************************
	echo. WARNING: Windows Resource Kits\Tools exist in "System Path"
	echo.    This can prevent some batch file commands from working properly.
	echo.        AMUMSS will not work until that is corrected.
	echo.
	echo.    Search for "Advanced System Settings"
	echo.      then click on "Environment Variables" to find the
	echo.      "System variables" panel.
	echo.      Select "Path" and click "Edit"
	echo.    
	echo.    Make sure to remove in your "System variables Path"
	echo.    any references to 'Windows Resource Kits\Tools' like:
	echo.      'C:\program files ^(x86^)\Windows Resource Kits\Tools\'
	echo.
	echo. *****************************************************************
	echo.

	pause
	exit
)
if defined _DEBUG (
	echo. D: NO Windows Resource Kits\Tools in PATH
	pause
)
if [%GoodSystemPath%]==[N] (
	echo. 
	echo. *****************************************************************
	echo.    Your "System Path" is missing important system paths
	echo.    This can prevent all batch files from working properly.
	echo.        AMUMSS will not work until that is corrected.
	echo.
	echo.    In Windows: Search for "Advanced System Settings"
	echo.      then click on "Environment Variables" to find
	echo.      the "System variables" panel.
	echo.      Select "Path" and click "Edit"
	echo.    
	echo.    Make sure ONE copy of these FOUR paths below
	echo.    exist in your "System variables"-^>"Path":
	echo.      a^) !SystemRoot!\system32
	echo.      b^) !SystemRoot!
	echo.      c^) !SystemRoot!\system32\Wbem
	echo.      d^) !SystemRoot!\system32\WindowsPowerShell\v1.0\
	echo.
	echo.      A reboot may be necessary for changes to take effect
	echo.
	echo. *****************************************************************
	echo. 
	
	pause
	exit
)
if defined _DEBUG (
	echo. E: passed PATH tests
	pause
)
rem https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing/8162578#8162578
rem let us set default options value here
rem the order of definition is irrelevant

rem these defaults can be overridden by calling like: BUILDMOD.bat -CombineModPak N -CopyToGamefolder NONE
rem     BETTER YET: USE BUILDMOD_AUTO.bat for easy control of the OPTIONS

rem     SEE 'README-OPTIONS_DEFINITIONS.txt' for OPTION definitions

rem  >>>>>>>>>>>>>>  DO NOT EVER MODIFY THIS LINE BELOW, modify BUILDMOD_AUTO.bat instead  <<<<<<<<<<<<<<<<<<
set "options=-AutoUpdateAMUMSS:"Y" -AutoUpdateMBinCompiler:"Y" -BackupReports:"10" -BackupType:"pak" -CheckForModConflicts:"M" -CLEANLOG:"Y" -CombineModPak:"ASK" -CopyToGamefolder:"ASK" -CreateUsefulUtilityScripts:"N" -DEV_MODE:"ASK" -EXPORTED:"N" -EXT_FUNC_Helper:"N" -GUIF_AllowRequests:"Y" -GUIF_DelayMult:"1.0" -FileStructureLevel:"1" -GameVersion:"ASK" -IncludeLuaScriptInPak:"Y" -IncludeTagsInEXML_MXML:"Y" -IncrementalBuilds:"3" -MAPFILETREE:"LUAPLUS" -MAPFILETREEFORCE:"N" -MODSfolderNameScript:"N" -NMSreStart:"N" -ReCreateMapFileTree:"N" -RecreatePAKList:"N" -SerializeScript:"N" -SHOWEXTRASECTIONS:"N" -SHOWOPTIONS:"N" -SHOWSECTIONS:"N" -SHOWSimpleContainer:"N" -SOUND:"Y" -TABtoSPACES:"2" -TestScript:"Y" -UseColors:"Y" -UseColorConfig:"Y" -UseColorConfigFile:"AMUMSS_colors.cfg" -UseExtraFilesInPAK:"ASK" -UseLastCompiler:"Y" -UseLuaScriptInPak:"ASK" -VerboseFinalREPORT:"Y""
rem  >>>>>>>>>>>>>>  DO NOT EVER MODIFY THIS LINE ABOVE, modify BUILDMOD_AUTO.bat instead  <<<<<<<<<<<<<<<<<<

for %%O in (%options%) do (for /f "tokens=1,* delims=:" %%A in ("%%O") do (set "%%A=%%~B"))
:loop
if not "%~1"=="" (
  set "test=!options:*%~1:=! "
  if "!test!"=="!options! " (
      echo. Error: Invalid option %~1
  ) else if "!test:~0,1!"==" " (
      set "%~1=1"
  ) else (
      setlocal disableDelayedExpansion
      set "val=%~2"
      call :escapeVal
      setlocal enableDelayedExpansion
	  CALL :UCase val val
      for /f delims^=^ eol^= %%A in ("!val!") do endlocal&endlocal&set "%~1=%%A" !
      shift /1
  )
  shift /1
  goto :loop
)
goto :endArgs

:escapeVal
set "val=%val:^=^^%"
set "val=%val:!=^!%"
exit /b

:endArgs
if [%-SHOWOPTIONS%]==[Y] (
	set -
	echo.
)

rem To get the value of a single parameter, just remember to include the `-`
REM echo The value of -CopyToGamefolder is: !-CopyToGamefolder!

rem --------------   Installed OS_2: get Lua.exe  -----------------------------
rem since MBINCompiler can only be used on x64 now
rem was !CD!
if exist ".\MODBUILDER\Extras\lua_x64\bin\lua.exe" set "_mLUA=Extras\lua_x64\bin\lua.exe"
if exist ".\MODBUILDER\Extras\lua_x64\bin\luaS.exe" set "_mLUAS=Extras\lua_x64\bin\luaS.exe"
if exist ".\MODBUILDER\Extras\lua_x64\bin\luaM.exe" set "_mLUAM=Extras\lua_x64\bin\luaM.exe"
set "_mLUAC=Extras\lua_x64\bin\luac.exe"
rem --------------  end Installed OS_2: get Lua.exe   -----------------------------

if defined _DEBUG (
	echo. F:
	pause
)
if [%-UseColors%]==[N] goto :SKIP_COLORS

for /f "tokens=2*" %%a in ('Reg Query "HKCU\Console" /v VirtualTerminalLevel') do set "VirtualTerminalLevel=%%~b"
set /a "VirtualTerminalLevel=%VirtualTerminalLevel%"

rem turn colors ON for win 10 1903 and before
reg add HKCU\Console /V VirtualTerminalLevel /T REG_DWORD /D 0x00000001 /F /reg:64 1>NUL 2>NUL

if [%VirtualTerminalLevel%]==[0] (
	echo. Please re-start BUILDMOD.bat, we had to enable colors in the registry
	pause
	exit
)

if defined _DEBUG (
	echo. G:
	pause
)
REM enable color output
if not defined bypass (
    for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "CurrentBuildHex=%%~b"
    set /a "_bCurrentBuildDec=!CurrentBuildHex!"
)

if defined bypass (
    set /a "_bCurrentBuildDec=10000"
)

if defined _DEBUG (
	echo. G_1: !_bCurrentBuildDec!
	pause
)
rem nothing to do to get colors for > win 10 1803 (18362)
REM if %_bCurrentBuildDec% LEQ 18362 (
	if %_bCurrentBuildDec% LEQ 7601 (
		rem for win 7 and before, use ansicon.exe instead
		.\MODBUILDER\ansicon_x64\ansicon.exe -p 1>NUL 2>NUL
		set "_ansicon=+"
	) else (
        if [%-UseColorConfig%]==[Y] (
            REM reset colors to AMUMSS_colors.ini (or user choices)
            rem .\MODBUILDER\ColorTool.exe -q .\CONFIG\%-UseColorToolInfo%

            .\MODBUILDER\%_mLUA% .\MODBUILDER\GetAMUMSS_colors.lua

            for /F "tokens=*" %%G IN (.\MODBUILDER\Colors_result.lua) DO %%G
            for /F "tokens=*" %%G IN (.\MODBUILDER\UsedColors_result.lua) DO %%G

        ) else (
            REM reset colors to cmd legacy values (or user choices)
            rem .\MODBUILDER\ColorTool.exe -q .\CONFIG\cmd-legacy.ini
        )
		REM rem turn colors ON for win 10 1903 and before
		REM reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f 1>NUL 2>NUL
	)
REM )

REM to check colors
REM set f
REM echo.
REM set b
REM echo.
REM pause

REM echo.
REM set _
REM echo.
REM set g
REM pause

REM REM enable color output
REM rem NOT USED, won't work on win 7, use ansicon.exe instead
REM rem reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f 1>NUL 2>NUL

REM .\MODBUILDER\ansicon_x64\ansicon.exe -p 1>NUL 2>NUL

if defined _DEBUG (
	echo. H:
	pause
)
REM if [%-UseColorConfig%]==[Y] (
    if not defined _zBRIGHTRED set "_zBRIGHTRED=[1;91m[1m"
    if not defined _zDARK_MAGENTA set "_zDARK_MAGENTA=[1;35m[1m"
    if not defined _zBRIGHTGREEN set "_zBRIGHTGREEN=[1;92m[1m"
    if not defined _zYELLOW set "_zYELLOW=[1;33m[1m"
    if not defined _zBRIGHTORANGE set "_zBRIGHTORANGE=[1;91m[1m"
    if not defined _zBRIGHTYELLOW set "_zBRIGHTYELLOW=[1;93m[1m"
    if not defined _zBLUE set "_zBLUE=[1;34m[1m"
    if not defined _zBRIGHTBLUE set "_zBRIGHTBLUE=[1;94m[1m"
    if not defined _zDARKGRAY set "_zDARKGRAY=[1;90m[1m"
    
    if not defined _zWHITEonDARKCYAN set "_zWHITEonDARKCYAN=[1;46m[1m"                
    if not defined _zWHITEonYELLOW set "_zWHITEonYELLOW=[1;43m[1m"
    if not defined _zWHITEonBLUE set "_zWHITEonBLUE=[1;44m[1m"
    if not defined _zBLUEonDARKGRAY set "_zBLUEonDARKGRAY=[34;47m"
    if not defined _zBLACKonYELLOW set "_zBLACKonYELLOW=[7;93m"
    if not defined _zBLUEonYELLOW set "_zBLUEonYELLOW=[34;43m"
                    
    if not defined gcERROR set "gcERROR=[33;41m[1m"
    if not defined gcWARNING set "gcWARNING=[95;44m[1m"
    if not defined gcNOTICE set "gcNOTICE=[97;104m[1m"
    if not defined gcATTENTION set "gcATTENTION=[7;33m[1m"
    
    REM set "_zBRIGHTRED=%fgBRIGHTRED%"
    REM set "_zBRIGHTGREEN=%fgBRIGHTGREEN%"
    REM set "_zYELLOW=%fgBRIGHTYELLOW%"
    REM set "_zDARKGRAY=%fgDARKBLACK%"
    REM set "_zWHITEonDARKCYAN=%fgBRIGHTWHITE%%bgDARKCYAN%"

    REM set "_zWHITEonBLUE=%fgBRIGHTWHITE%%bgBRIGHTBLUE%"
    REM set "_zWHITEonYELLOW=%fgBRIGHTWHITE%%bgBRIGHTYELLOW%"
    REM set "_zBLUEonDARKGRAY=%fgBRIGHTBLUE%%bgDARKBLACK%"
    REM set "_zBLACKonYELLOW=%fgDARKBLACK%%bgBRIGHTYELLOW%"

    REM set "gcERROR=%fgBRIGHTYELLOW%%bgBRIGHTRED%"
    REM set "gcWARNING=%fgBRIGHTMAGENTA%%bgBRIGHTORANGE%"
    REM set "gcNOTICE=%fgBRIGHTWHITE%%bgBRIGHTBLUE%"
    REM set "gcATTENTION=%fgDARKBLACK%%bgBRIGHTYELLOW%"
REM ) else (
    REM rem use defaults
    REM set "_zBRIGHTRED=[1;91m[1m"
    REM set "_zBRIGHTGREEN=[1;92m[1m"
    REM set "_zYELLOW=[1;33m[1m"
    REM set "_zDARKGRAY=[1;90m[1m"
    REM set "_zWHITEonDARKCYAN=[1;46m[1m"

    REM set "_zWHITEonBLUE=[1;44m[1m"
    REM set "_zWHITEonYELLOW=[1;43m[1m"
    REM set "_zBLUEonDARKGRAY=[34;47m"
    REM set "_zBLACKonYELLOW=[7;93m"

    REM set "gcERROR=[33;41m[1m"
    REM set "gcWARNING=[95;44m[1m"
    REM set "gcNOTICE=[97;104m[1m"
    REM set "gcATTENTION=[7;33m[1m"
REM )

REM echo.
REM set _
REM echo.
REM set g
REM pause

set "_zBGintense=[100m"
set "_zINVERSE=[7m"

set "_zDEFAULT=[0m"

:SKIP_COLORS
set "_zUpOneLine=[F"
set "_zUpOneLineErase=[F[K"

Del /f /q "log.lua" 1>NUL 2>NUL

if defined _DEBUG (
	echo. I:
	pause
)
if not exist "MODBUILDER\UpdatePackage" (
	mkdir "MODBUILDER\UpdatePackage\" 2>NUL
) else (
	Del /f /q /s "MODBUILDER\UpdatePackage\*.*" 1>NUL 2>NUL
)

if not exist "MODBUILDER\UpdatePackage_CONTENT" (
	mkdir "MODBUILDER\UpdatePackage_CONTENT\" 2>NUL
) else (
	Del /f /q /s "MODBUILDER\UpdatePackage_CONTENT\*.*" 1>NUL 2>NUL
)

set /p _CurrentVersion=<MODBUILDER\AMUMSSVersion.txt 1>NUL 2>NUL

REM if exist "MODBUILDER\AMUMSSMasterVersion.txt" (
	REM set /p _MasterVersion=<MODBUILDER\AMUMSSMasterVersion.txt 1>NUL 2>NUL
REM ) else (
	REM set "_MasterVersion=%_CurrentVersion%"
	REM echo|set /p="!_MasterVersion!">"MODBUILDER\AMUMSSMasterVersion.txt"
REM )

echo.
REM echo.  MasterVersion = [%_MasterVersion%]
echo. CurrentVersion = [%_CurrentVersion%] Checking for updates, please wait...
echo.

set "myPath=https://raw.githubusercontent.com/HolterPhylo/AMUMSS/main/AMUMSS/MODBUILDER/UPDATE/"

if exist "..\UpdatePackage_DEBUG\CreatedUpdatePackage.!_CurrentVersion:W=!.pak" (
	REM echo. Found ..\UpdatePackage_DEBUG folder
	REM pause
	set "_debugging=Y"
    set "myPath=..\UpdatePackage_DEBUG\"
)

if defined _DEBUG (
	echo. J:
	pause
)
set "myPathCUP_url=!myPath!CreatedUpdatePackage.!_CurrentVersion:W=!.pak"
rem like: https://raw.githubusercontent.com/HolterPhylo/AMUMSS/main/AMUMSS/MODBUILDER/UPDATE/CreatedUpdatePackage.3.9.5.92.pak
rem echo.%myPathCUP_url%
set "_curlpath=.\MODBUILDER\MBINCompilerDownloader\"
if exist %SYSTEMROOT%\system32\curl.exe (
    set "_curlExist=*"
    REM echo.       **** windows curl.exe exist ****
    set "_curlpath=%SYSTEMROOT%\system32\"
)

if defined _debugging (
	echo. xxxx _debugging is active: using package: !myPathCUP_url! xxxx
	xcopy /y /h /i /j /r "!myPathCUP_url!" "MODBUILDER/UpdatePackage/UpdatePackage.pak*" 1>NUL 2>NUL
) else (
    %_curlpath%curl.exe -s --ssl-no-revoke --connect-timeout 30 "!myPathCUP_url!" >MODBUILDER/UpdatePackage/UpdatePackage.pak
)

set /p _packageExist=<"MODBUILDER\UpdatePackage\UpdatePackage.pak" 1>NUL 2>NUL
rem [404: Not Found]
rem echo._packageExist = [%_packageExist%]

set "_packageExist=%_packageExist:404: =%"

if ["%_packageExist%"]==["Not Found"] (
	echo. ===^> %_curlExist%%_ansicon% No further update currently available
) else (
    rem echo. [!_packageExist!]
    if ["!_packageExist!"]==["404: ="] (
        echo. ===^> %_curlExist%%_ansicon% Checking for updates is currently unavailable, internet problem?
    ) else (
        echo. ===^> %_curlExist%%_ansicon% update available
    )
)

if defined _DEBUG (
	echo. K:
	pause
)
if ["%_packageExist%"]==["PSAR"] (
	echo. ===^> update package is valid
	set "_AMUMSS_PATH=!CD!"
	
	REM if defined _dev (
		REM set "_AMUMSS_PATH=!CD!\MODBUILDER\UpdatePackage_CONTENT"
	REM )
	
	cd MODBUILDER
	set "_MODBUILDER_PATH=!CD!"
	
	psarc.exe extract "UpdatePackage/UpdatePackage.pak" "MODBUILDER/AMUMSSVersion.txt" --to="!_MODBUILDER_PATH!\UpdatePackage_CONTENT" -y >nul
	cd ..
	
	set /p _packageVersion=<"MODBUILDER\UpdatePackage_CONTENT\MODBUILDER\AMUMSSVersion.txt" 1>NUL 2>NUL
	
	if not [!_CurrentVersion!]==[!_packageVersion!] (
		echo. ===^> New version available [!_packageVersion!]
		echo.
		
		if [!-AutoUpdateAMUMSS!]==[Y] goto :AUTO_UPDATE
		
		CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Would you like to UPDATE AMUMSS version (recommended) %_zDEFAULT%"
		if !ERRORLEVEL! EQU 2 goto :CancelledByUser

		:AUTO_UPDATE
		cd MODBUILDER
		psarc.exe extract "UpdatePackage/UpdatePackage.pak" --to="!_AMUMSS_PATH!" -y >nul
		cd ..

		set /p _UpdatedVersion=<"MODBUILDER\AMUMSSVersion.txt" 1>NUL 2>NUL

		REM if defined _dev (
			REM set /p _UpdatedVersion=<"MODBUILDER\UpdatePackage_CONTENT\MODBUILDER\AMUMSSVersion.txt" 1>NUL 2>NUL
		REM )

		if [!_packageVersion!]==[!_UpdatedVersion!] (
			echo. ===^> Update completed successfully, see README-What's_new.txt for details
			set "_updateDone=Y"

			if exist "MODBUILDER\Delete_this.txt" (
                FOR /F "delims=" %%G in (MODBUILDER\Delete_this.txt) do (
                    if exist "%%G" (
                        Del /f /q "%%G" 1>NUL 2>NUL
                        RD "%%G" 1>NUL 2>NUL
                    )
                )
            )

			REM to force a refresh
			if exist "MODBUILDER\MBINCompiler.exe" (
				Del /f /q "MODBUILDER\MBINCompiler.exe" 1>NUL 2>NUL
            )
			
			echo.
			echo. %_zBLACKonYELLOW% A NEW update may exist, re-start BUILDMOD.bat to check %_zDEFAULT%
			pause
			start "" MODBUILDER\buildmod_update.bat
			exit
		)
	) else (
		echo. ===^> update already installed for version !_packageVersion!
	)
)		
goto :RUN

:CancelledByUser
echo. ===^> UPDATE cancelled by user

:RUN
echo. ===^> here we go...
rem echo.

rem /B /wait "" /MIN: order is important for it to work on win7 and early win10 version

rem original: works but prevents closing this until spawned worker(s) finish 
rem   and on Gumsk PC, goes to cmd prompt instead of closing cmd window (does not do that here)
rem START /b "" bzrun.bat 2>&1 | MODBUILDER\wtee.exe log.lua

REM set "SystemPath=%SystemRoot%\System32"
REM if not "%ProgramFiles(x86)%"=="" (
    REM if exist %SystemRoot%\Sysnative\* set "SystemPath=%SystemRoot%\Sysnative"
REM )
REM echo. %SystemPath%

REM If exist %windir%\SYSNATIVE\cmd.exe (
    REM echo 64bit OS - 32bit CMD
REM ) else (
    REM if exist %windir%\SYSWOW64\cmd.exe (
        REM echo 64bit OS - 64bit CMD
    REM ) else (
        REM echo 32bit OS - 32bit CMD
    REM )
REM )
REM pause

if exist MODBUILDER\bzrunM.bat (
	Del /f /q bzrun.bat 1>NUL 2>NUL
	if "%ProgramFiles(x86)%" == "" (
		REM echo. running on 32-bit windows
		set "_bzrunM=x32"
		echo.        using bzrunM.bat 32-bit
		echo.
		CALL MODBUILDER\bzrunM.bat 2>&1 | (MODBUILDER\tee.exe log.lua)
		REM echo.E0: %TIME%
	) else (
		REM echo. running on 64-bit windows
		if not exist "%SYSTEMROOT%\Sysnative\cmd.exe" (
			REM echo. hmm, cannot access 64-bit apps
			set "_bzrunM=x64"
			echo.        using bzrunM.bat on 64-bit system
			echo.
			CALL MODBUILDER\bzrunM.bat 2>&1 | (MODBUILDER\tee.exe log.lua)
			REM echo.E1: %TIME%
		) else (
			set "_bzrunM=x64"
			echo.        using bzrunM.bat 64-bit from 32-bit cmd
			echo.
			CALL "%SYSTEMROOT%\Sysnative\cmd.exe" /c MODBUILDER\bzrunM.bat 2>&1 | (MODBUILDER\tee.exe log.lua)
			REM echo.E2: %TIME%
		)
	)
	
) else (
    REM echo. using normal bzrun.bat
    echo.
	CALL bzrun.bat 2>&1 | (MODBUILDER\tee.exe log.lua)
	REM echo.E3: %TIME%
)
rem works and does not prevent closing this until spawned worker(s) finish
rem   BUT does not display to console
rem START /b "" /wait bzrun.bat 2>&1 >log.lua

rem does not echo to console with /b
rem   opens a new window without it
rem not good
rem START /wait "" bzrun.bat 2>&1 >log.lua

rem works but slow and still prevents closing this until spawned worker(s) finish 
rem START /b "" bzrun.bat 2>&1 | tee.bat log.lua 1

rem START /b "" bzrun.bat 2>&1 | tee2.bat log.lua

rem also works but prevents closing this until spawned worker(s) finish 
rem START /b /wait "" bzrunHelper.bat

REM this works from lua
REM -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
REM os.execute([[START "CreateMapFileTree" /MIN ]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]])

REM E? times above will be wrong, like before D? times in bzrunM.bat (VERY strange!!!)
REM echo.E4: %TIME%

if [%-NMSreStart%]==[N] goto :LAST

echo. Checking NMS.exe status...
set /p _bNMS_FOLDER=<.\CONFIG\NMS_FOLDER.txt 1>NUL 2>NUL
set "_bNMS_Binaries_FOLDER=%_bNMS_FOLDER%\Binaries\"

if exist %_bNMS_Binaries_FOLDER%NMS.exe (
	tasklist /FI "IMAGENAME eq NMS.exe"  /V /Fo CSV 2>NUL|"%__AppDir__%find.exe" /I "NMS.exe">NUL&&(set "NMSrunning=opened")||set "NMSrunning=closed")
	if [!NMSrunning!]==[opened] (
		rem echo.   ^>^>^> NMS.exe is already open
		CHOICE /c:yn /m " !_zBLACKonYELLOW! ??? NMS.exe is running.  Do you want to restart it !_zDEFAULT!"
		if !ERRORLEVEL! EQU 1 (
			echo. Killing and Restarting NMS.exe...
			TASKKILL.exe /F /FI "IMAGENAME eq NMS.exe" 1>NUL 2>NUL

			rem echo. Restarting NMS, please wait...
			START "" /B "%_bNMS_Binaries_FOLDER%NMS.exe" 1>NUL 2>NUL
			PING -n 6 127.0.0.1>nul
		REM ) else (
			REM echo. NMS.exe is still running...
			REM PING -n 3 127.0.0.1>nul
		)
	) else (
		echo. Starting NMS...
		START "" /B "%_bNMS_Binaries_FOLDER%NMS.exe" 1>NUL 2>NUL
		rem PING -n 6 127.0.0.1>nul
	)

REM ) else (	
	REM REM echo.%_zBLACKonYELLOW% === PRESS ANY KEY and THIS window will close shortly after cleaning log.lua === %_zDEFAULT%
	REM REM echo.%_zBLACKonYELLOW% === THIS window will close shortly after cleaning log.lua === %_zDEFAULT%
	REM echo.%_zBLACKonYELLOW% === PRESS ANY KEY to close this window === %_zDEFAULT%
	REM pause >nul
)

:LAST
REM echo.F: %TIME%

cd TOOLS
set "command=Check_Log_file.bat"
rem START /b /WAIT "" /MIN "%command%"
START /b /WAIT "Checking log.lua file" /MIN "%command%"

REM echo.%_zBLACKonYELLOW% === PRESS ANY KEY and THIS window will close shortly after cleaning log.lua === %_zDEFAULT%
REM echo.%_zBLACKonYELLOW% === THIS window will close shortly after cleaning log.lua === %_zDEFAULT%
if [%-SOUND%]==[Y] (
	echo. %_zBLACKonYELLOW% === PRESS ANY KEY to close this window === %_zDEFAULT%
) else (
	echo.%_zBLACKonYELLOW% === PRESS ANY KEY to close this window === %_zDEFAULT%
)
pause >nul

:CLEANLOG
REM echo.G: %TIME%

if [%-CLEANLOG%]==[N] goto :ENDING

rem needs to be standing alone
REM echo. Cleaning log.lua...
rem cd TOOLS
set "command=Log_file_cleaner.bat"
rem START /b /WAIT "" /MIN "%command%"
START /b "Cleaning log.lua file" /MIN "%command%"

:ENDING
goto :eof
rem *****************************************************************************************
rem               --------------------- WE ARE DONE ---------------------
rem *****************************************************************************************

rem --------------------------------------------
rem subroutine section starts below

rem --------------------------------------------
rem https://www.robvanderwoude.com/battech_convertcase.php
:LCase
:UCase
	:: Converts to upper/lower case variable contents
	:: Syntax: CALL :UCase _VAR1 _VAR2
	:: Syntax: CALL :LCase _VAR1 _VAR2
	:: _VAR1 = Variable NAME whose VALUE is to be converted to upper/lower case
	:: _VAR2 = NAME of variable to hold the converted value
	:: Note: Use variable NAMES in the CALL, not values (pass "by reference")

	SET "_UCase=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
	REM SET _LCase=a b c d e f g h i j k l m n o p q r s t u v w x y z
	SET "_Lib_UCase_Tmp=!%1!"
	IF /I "%0"==":UCase" SET _Abet=%_UCase%
	REM IF /I "%0"==":LCase" SET _Abet=%_LCase%
	FOR %%Z IN (%_Abet%) DO SET _Lib_UCase_Tmp=!_Lib_UCase_Tmp:%%Z=%%Z!
	SET "%2=%_Lib_UCase_Tmp%"
	exit /b
