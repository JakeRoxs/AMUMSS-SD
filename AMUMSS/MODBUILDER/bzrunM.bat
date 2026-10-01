@echo off
if not defined _mOK (
    echo.  Please use BUILDMOD.bat or BUILDMOD_AUTO.bat...
    pause
    EXIT
)
REM if exist WOPT_DEBUG.txt (
    REM if not defined _min_subprocess ((cmd /k set _min_subprocess=y ^& %0 %*) & exit )
    REM echo.################ IN DEBUG MODE ################
    REM echo.
REM )

if exist "BUILDMOD_OLD.bat" (
    del "BUILDMOD_OLD.bat" 1>NUL 2>NUL
)

if EXIST MODBUILDER\UsingAMM.txt (
    Del /f /q "MODBUILDER\UsingAMM.txt" 1>NUL 2>NUL
    set "_bUsingAMM=Y"
    
    if EXIST MODBUILDER\UsingAUTO.txt (
        set "_bUsingAMM_AUTO=Y"
    )
)

REM BUGS BUGS BUGS
rem Bugs: https://ss64.com/nt/goto.html
rem Using GOTO within parenthesis - including FOR and IF commands - will break their context
rem () inside echo can break things, use ^(^)
rem remarks with :: do not work in FOR loops

rem A few Windows tools, such as find.exe, link.exe and sort.exe, may conflict with the Cygwin versions
rem make sure that you use them like %SystemRoot%\system32\Find.exe

REM FINDSTR usage: see https://superuser.com/questions/1535810/is-there-a-better-way-to-mitigate-this-obscure-color-bug-when-piping-to-findstr

REM for /r [[drive:]path] %%parameter IN (set) DO command
rem     path can NOT use "!xyz!" as the expansion happens AFTER 'for' is initiated, must used "%xyz%" as a minimum
rem https://stackoverflow.com/questions/8588927/batch-for-r-doesnt-work-with-a-variable-in-the-path
rem https://stackoverflow.com/questions/30335159/windows-cmd-batch-for-r-with-delayedexpansion

REM End: BUGS BUGS BUGS

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
set "_sysDrive=%SYSTEMDRIVE%"
set "_bSystem32=%SYSTEMROOT%\system32"

title AMUMSS %_CurrentVersion% (%_bzrunM%) --^> %CD%

REM rem -------------  testing for administrator  -------------------------------
REM set _bMyPath=%CD%
REM if [%_bMyPath%]==[%_bSystem32%] set _bADMIN=1

REM if DEFINED _bADMIN (
    REM echo.[ERROR] Please do NOT "Run as administrator", AMUMSS will not work^!
    REM pause
    REM goto :eof
REM )

REM set _bMyPath=
REM set _bADMIN=
REM rem -------------  end testing for administrator  -------------------------------

rem goto Start-up (AMUMSS) folder
rem could remove the need for testing for administrator ???
rem cd /D "%~dp0"
cd /D %CD%

rem set _pause=Y

if defined _pause (
    echo A: AMUMSS: current directory: !CD!
    pause
)

rem set "_bMASTER_FOLDER_PATH=%~dp0"
rem \ is required with %CD%
set "_bMASTER_FOLDER_PATH=%CD%\"

rem echo|set /p="%~dp0">MASTER_FOLDER_PATH.txt
rem echo|set /p="%~dp0">.\MODBUILDER\MASTER_FOLDER_PATH.txt

rem MASTER_FOLDER_PATH.txt is needed by certain functions
rem \ is required with %CD%
echo|set /p="%CD%\">.\MODBUILDER\MASTER_FOLDER_PATH.txt

rem -------------  testing for AMUMSS path  -------------------------------
set "_search=("
CALL set "_testPath=%%_bMASTER_FOLDER_PATH:%_search%=%%"
if /i NOT ["%_testPath%"]==["%_bMASTER_FOLDER_PATH%"] set "_found=Y"
if defined _found (
    echo. %_zBRIGHTRED%%_bB% Path to AMUMSS contains parenthesis ^(^), please remove them and retry%_zDEFAULT%
    pause
    exit
)
rem -------------  END: testing for AMUMSS path  -------------------------------

REM rem --------------   Installed OS_2: get Lua.exe  -----------------------------
REM rem since MBINCompiler can only be used on x64 now
REM rem was !CD!
REM if exist ".\MODBUILDER\Extras\lua_x64\bin\lua.exe" set "_mLUA=Extras\lua_x64\bin\lua.exe"
REM if exist ".\MODBUILDER\Extras\lua_x64\bin\luaS.exe" set "_mLUAS=Extras\lua_x64\bin\luaS.exe"
REM if exist ".\MODBUILDER\Extras\lua_x64\bin\luaM.exe" set "_mLUAM=Extras\lua_x64\bin\luaM.exe"
REM set "_mLUAC=Extras\lua_x64\bin\luac.exe"
REM rem --------------  end Installed OS_2: get Lua.exe   -----------------------------

SET "_bDateTimeStart=  %DATE% %TIME% AMUMSS starting^!"
echo.!_bDateTimeStart!
if [%-UseColorTool%]==[Y] (
    if [%-UseColorTool%]==[Y] (
        echo.%_zBRIGHTGREEN%    Using AMUMSS colors%_zDEFAULT%
    ) else (
        echo.%_zBRIGHTGREEN%    Using LEGACY colors%_zDEFAULT%
    )
)

rem *********************  NOW IN AMUMSS folder  *******************

if exist WOPT_SERIALIZING.txt (set "_mSERIALIZING=Y")
if exist WOPT_DEBUG.txt (set "_mDEBUG=y")
if exist WOPT_PSARC.txt (set "_mPSARC=Y")
if exist WOPT_DEV.txt (set "_mDEV=y")
if exist WOPT_ISxxx.txt (set "_mISxxx=Y")
if exist WOPT_PAUSE.txt (set "_mPAUSE=y")
if exist WOPT_VERBOSE_BATCH.txt (set "_mVERBOSE=y")
if exist WOPT_Wbertro.txt (set "_mWbertro=y")
if exist WOPT_GlobalRepl.txt (set "_mGlobalRepl=y")
if exist WOPT_UnusedVariable.txt (set "_mUnusedVariable=Y")
if exist WOPT_NoGUIFWait.txt (set "_mNoGUIFWait=Y")

if defined _mDEV (
    if exist LoadAndExecuteModScript_DEV.lua (
		echo. %gcWARNING% USING LoadAndExecuteModScript_DEV %_zDEFAULT%
	) else (
		set _mDEV=
	)
)
REM not required anymore
REM if exist WOPT_SIMPLE.txt (set _mSIMPLE=y)

REM SET /p _mMasterVersion=<"MODBUILDER\AMUMSSMasterVersion.txt"
SET /p _mCurrentVersion=<"MODBUILDER\AMUMSSVersion.txt"

REM if [!_mMasterVersion!]==[] set "_mMasterVersion=_mCurrentVersion"

if defined _mDEBUG (
    echo.
    echo. =========== as received from BUILDMOD.bat =================
    echo. ========== may be using BUILDMOD_AUTO.bat =================
    echo.   -CombineModPak = [%-CombineModPak%]
    REM echo. -CombinedModType = [%-CombinedModType%]
    echo. ===========================================================
)

if defined _bUsingAMM (
    if not defined _bUsingAMM_AUTO (
        rem auto select Individual pak unless a ___COMBINE.txt flag exist
        set "_bAMM_AUTOselect=Y"

        rem INDIVIDUAL mod
        SET "_bCOMBINE_MOD_TYPE=0"
        
        set "-CombineModPak=N"
        REM set "-CombinedModType=3"
    ) else (
        rem auto select Individual pak unless a ___COMBINE.txt flag exist
        set "_bAMM_AUTOselect=Y"

        rem INDIVIDUAL mod
        SET "_bCOMBINE_MOD_TYPE=0"
        REM SET "_bCOMBINE_MOD_TYPE=%-CombinedModType%"
        
        set "-CombineModPak=N"
    )
)

if not exist ".\ModScript" (
    mkdir ".\ModScript\" 2>NUL
) else (
    REM echo. Deleting *.luax files...
    set "command=cmd /c Del /f /q /s "*.luax" 1>NUL 2>NUL"
    rem /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
    START "Cleaning Old .luax files" /MIN "!command!"
)

REM when AMM is NOT used:
REM   the user must be able to USE scripts in ModScript AND decide if they should be combined or not
if not defined _bUsingAMM (
    pushd .\ModScript
    rem I should do: always use and not combine
    
    rem FORCE USE
    ren "___DONOTUSE.txt" "___USE.txt" 1>NUL 2>NUL
    if not exist "___USE.txt" (
        echo >___USE.txt
    )
    rem FORCE NO COMBINE for now
    ren "___COMBINE.txt" "___COMBINEx.txt"  1>NUL 2>NUL
    if not exist "___COMBINE.txt" (
        echo >___COMBINEx.txt
    )
    popd
)

if defined _mDEBUG (
    if defined _bUsingAMM (
        if not defined _bUsingAMM_AUTO (
            echo. =========== AMM, without AUTO =================
            echo.   -CombineModPak = [!-CombineModPak!]
            REM echo. -CombinedModType = [!-CombinedModType!]
            echo. ==========================================================
        ) else (
            echo. =========== AMM, with AUTO ===============================
            echo.   -CombineModPak = [!-CombineModPak!]
            REM echo. -CombinedModType = [!-CombinedModType!]
            echo. ==========================================================
        )
    )
)

REM REM ------------------------  Display date independent of OS Locale, Language or date format.
REM rem https://ss64.com/nt/syntax-getdate.html
REM Setlocal
REM Set t=2&if "%date%z" LSS "A" set t=1
REM For /f "skip=1 tokens=2-4 delims=(-)" %%A in ('echo/^|date') do (
  REM for /f "tokens=%t%-4 delims=.-/ " %%J in ('date/t') do (
    REM set %%A=%%J&set %%B=%%K&set %%C=%%L)
REM )
REM Endlocal&set _yyyy=%yy%&set _mm=%mm%&set _dd=%dd%

REM rem _mm and _dd must be like 00
REM if %_yyyy% GEQ 2023 (
    REM if %_mm% GEQ 07 (
        REM if %_dd% GEQ 08 (
            REM set _TestNet6=Y
        REM )
    REM )
REM )
REM echo. _TestNet6=[%_TestNet6%]

rem "%__AppDir__%WindowsPowerShell\v1.0\powershell.exe" -NoP "$HW=(Get-Host).UI.RawUI;'Window size = '+$HW.WindowSize;'Buffer size = '+$HW.BufferSize"
For /F Delims^= %%G In ('PowerShell.exe -NoP "$HW=(Get-Host).UI.RawUI;'_WinWxH='+$HW.WindowSize -Replace ',','x';'_BufWxH='+$HW.BufferSize -Replace ',','x'"')Do @Set "%%G"
REM echo. _WinWxH = %_WinWxH%
REM echo. _BufWxH = %_BufWxH%
REM pause

rem --------------   Installed DOTNET   -----------------------------
REM set "_TestNet5=Y"
set "_TestNet6=Y"
set "_TestNet8=Y"
set "_MasterDOTNET=8"

set "_bNetVer=5"
set "_bDotNet=.NET %_bNetVer% unknown"
set "DotNet5=%_bDotNet%"

REM could also look into:
REM HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost
REM key = path
REM returns: C:\Program Files\dotnet\

if exist "!_sysDrive!\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
    set "_bDotNet=.NET %_bNetVer% x64 Desktop Runtime exist"
) else (
    dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
    MODBUILDER\%_mLUA% .\MODBUILDER\GetDotnetPath.lua
    set /p _bDotnetPath=<"MODBUILDER\DotnetPath.txt"
    if exist "!_bDotnetPath!Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
        set "_bDotNet=.NET %_bNetVer% x64 Desktop Runtime exist"
    )
)

REM REM FOR TEST
REM set "_bDotNet=.NET %_bNetVer% unknown"

REM echo. _TestNet5=[%_TestNet5%]
if defined _TestNet5 (
    REM echo. YYY %_bDotNet% %_bNetVer%
    if ["%_bDotNet%"]==[".NET %_bNetVer% unknown"] (
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%%_zDEFAULT%%_zWHITEonDARKCYAN% .NET %_bNetVer% x64 Desktop Runtime %_zDEFAULT%%_zBLACKonYELLOW% SHOULD be installed before continuing %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      Not 'Core' or 'ASP', and no other version will do^^!           %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   NOTE: do not remove any already installed .net versions         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%  NEEDED IF you EVER have to de/compile MBIN files from OLDER paks %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Press 'Y' to install .NET %_bNetVer% x64 Desktop Runtime on your machine, 'N' to continue %_zDEFAULT%"
        if !ERRORLEVEL! EQU 2 goto :SKIPDOTNET5
        if !ERRORLEVEL! EQU 1 set "_bInstallNET%_bNetVer%=1"
        
        if !_bInstallNET%_bNetVer%! EQU 1 (
            echo.
            echo. Follow the instructions if any appear ^(User Account Control may ask for permission^)
            echo.    ^(downloading may take a minute^) and installing please wait...
            winget install --architecture x64 Microsoft.Dotnet.DesktopRuntime.%_bNetVer%
            rem 1>NUL 2>NUL
        )
        
        rem retest
        if exist "!_sysDrive!\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
            echo. Done^^!
            set "_bDotNet=.NET !_bNetVer! x64 Desktop Runtime exist"
        ) else (
            echo. Checking alternate path...
			dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
            MODBUILDER\%_mLUA% .\MODBUILDER\GetDotnetPath.lua
            set /p _bDotnetPath=<"MODBUILDER\DotnetPath.txt"
            if exist "!_bDotnetPath!Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\!_bNetVer!.?.??" (
				echo. Done^^!
                set "_bDotNet=.NET !_bNetVer! x64 Desktop Runtime exist"
            )
        )
    )
    
    REM echo. YYY %_bDotNet%
    REM echo. YYY !_bDotNet!
	
    if ["!_bDotNet!"]==[".NET %_bNetVer% unknown"] (
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    Sorry, could not complete automatic install                    %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%%_zDEFAULT%%_zWHITEonDARKCYAN% .NET %_bNetVer% x64 Desktop Runtime %_zDEFAULT%%_zBLACKonYELLOW% SHOULD be installed before continuing %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      Not 'Core' or 'ASP', and no other version will do^^!           %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    IF you plan to compile-decompile older MBIN files              %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   NOTE: do not remove any already installed .net versions         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    goto 'https://dotnet.microsoft.com/en-us/download/dotnet/%_bNetVer%.0'  %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    and select the '.NET Desktop Runtime %_bNetVer%.?.?? Windows x64'       %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        pause
        REM dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
        REM echo.
        echo. --- FOR INFO: Currently installed versions are ---
        type "MODBUILDER\DOTNET.txt"
        echo.
        pause
        REM exit
    )
)
:SKIPDOTNET5
set "DotNet5=%_bDotNet%"

set "_bNetVer=6"
set "_bDotNet=.NET %_bNetVer% unknown"
set "DotNet6=%_bDotNet%"

REM could also look into:
REM HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost
REM key = path
REM returns: C:\Program Files\dotnet\

if exist "!_sysDrive!\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
    set "_bDotNet=.NET %_bNetVer% x64 Desktop Runtime exist"
) else (
    dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
    MODBUILDER\%_mLUA% .\MODBUILDER\GetDotnetPath.lua
    set /p _bDotnetPath=<"MODBUILDER\DotnetPath.txt"
    if exist "!_bDotnetPath!Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
        set "_bDotNet=.NET %_bNetVer% x64 Desktop Runtime exist"
    )
)

REM REM FOR TEST
REM set "_bDotNet=.NET %_bNetVer% unknown"

REM echo. _TestNet6=[%_TestNet6%]
if defined _TestNet6 (
    REM echo. ZZZ %_bDotNet% %_bNetVer%
    if ["%_bDotNet%"]==[".NET %_bNetVer% unknown"] (
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%%_zDEFAULT%%_zWHITEonDARKCYAN% .NET %_bNetVer% x64 Desktop Runtime %_zDEFAULT%%_zBLACKonYELLOW% MUST be installed before continuing   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      Not 'Core' or 'ASP', and no other version will do^^!           %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%           .NET 7 and above are NOT compatible                     %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   NOTE: do not remove any already installed .net versions         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Press 'Y' to install .NET %_bNetVer% x64 Desktop Runtime on your machine, 'N' to exit %_zDEFAULT%"
        if !ERRORLEVEL! EQU 2 exit
        if !ERRORLEVEL! EQU 1 set "_bInstallNET%_bNetVer%=1"
        
        if !_bInstallNET%_bNetVer%! EQU 1 (
            echo.
            echo. Follow the instructions if any appear ^(User Account Control may ask for permission^)
            echo.    ^(downloading may take a minute^) and installing please wait...
            winget install --architecture x64 Microsoft.Dotnet.DesktopRuntime.%_bNetVer%
            rem 1>NUL 2>NUL
        )
        
        rem retest
        if exist "!_sysDrive!\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
            echo. Done^^!
            set "_bDotNet=.NET !_bNetVer! x64 Desktop Runtime exist"
        ) else (
            echo. Checking alternate path...
            dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
            MODBUILDER\%_mLUA% .\MODBUILDER\GetDotnetPath.lua
            set /p _bDotnetPath=<"MODBUILDER\DotnetPath.txt"
            if exist "!_bDotnetPath!Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\!_bNetVer!.?.??" (
				echo. Done^^!
                set "_bDotNet=.NET !_bNetVer! x64 Desktop Runtime exist"
            )
        )
    )
    if ["!_bDotNet!"]==[".NET %_bNetVer% unknown"] (
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    Sorry, could not complete automatic install                    %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%%_zDEFAULT%%_zWHITEonDARKCYAN% .NET %_bNetVer% x64 Desktop Runtime %_zDEFAULT%%_zBLACKonYELLOW% MUST be installed before continuing   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      Not 'Core' or 'ASP', and no other version will do^^!           %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%           .NET 7 and above are NOT compatible                     %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   NOTE: do not remove any already installed .net versions         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    goto 'https://dotnet.microsoft.com/en-us/download/dotnet/%_bNetVer%.0'  %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    and select the '.NET Desktop Runtime %_bNetVer%.?.?? Windows x64'       %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        pause
        REM dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
        REM echo.
        echo. --- FOR INFO: Currently installed versions are ---
        type "MODBUILDER\DOTNET.txt"
        echo.
        pause
        exit
    )
)
set "DotNet6=%_bDotNet%"

set "_bNetVer=8"
set "_bDotNet=.NET %_bNetVer% unknown"
set "DotNet8=%_bDotNet%"

REM could also look into:
REM HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost
REM key = path
REM returns: C:\Program Files\dotnet\

if exist "!_sysDrive!\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
    set "_bDotNet=.NET %_bNetVer% x64 Desktop Runtime exist"
) else (
    dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
    MODBUILDER\%_mLUA% .\MODBUILDER\GetDotnetPath.lua
    set /p _bDotnetPath=<"MODBUILDER\DotnetPath.txt"
    if exist "!_bDotnetPath!Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
        set "_bDotNet=.NET %_bNetVer% x64 Desktop Runtime exist"
    )
)

REM REM FOR TEST
REM set "_bDotNet=.NET %_bNetVer% unknown"

REM echo. _TestNet6=[%_TestNet6%]
if defined _TestNet8 (
    REM echo. ZZZ %_bDotNet% %_bNetVer%
    if ["%_bDotNet%"]==[".NET %_bNetVer% unknown"] (
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%%_zDEFAULT%%_zWHITEonDARKCYAN% .NET %_bNetVer% x64 Desktop Runtime %_zDEFAULT%%_zBLACKonYELLOW% MUST be installed before continuing   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      Not 'Core' or 'ASP', and no other version will do^^!           %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%           .NET 9 and above are NOT compatible                     %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   NOTE: do not remove any already installed .net versions         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Press 'Y' to install .NET %_bNetVer% x64 Desktop Runtime on your machine, 'N' to exit %_zDEFAULT%"
        if !ERRORLEVEL! EQU 2 exit
        if !ERRORLEVEL! EQU 1 set "_bInstallNET%_bNetVer%=1"
        
        if !_bInstallNET%_bNetVer%! EQU 1 (
            echo.
            echo. Follow the instructions if any appear ^(User Account Control may ask for permission^)
            echo.    ^(downloading may take a minute^) and installing please wait...
            winget install --architecture x64 Microsoft.Dotnet.DesktopRuntime.%_bNetVer%
            rem 1>NUL 2>NUL
        )
        
        rem retest
        if exist "!_sysDrive!\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\%_bNetVer%.?.??" (
            echo. Done^^!
            set "_bDotNet=.NET !_bNetVer! x64 Desktop Runtime exist"
        ) else (
            echo. Checking alternate path...
            dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
            MODBUILDER\%_mLUA% .\MODBUILDER\GetDotnetPath.lua
            set /p _bDotnetPath=<"MODBUILDER\DotnetPath.txt"
            if exist "!_bDotnetPath!Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\!_bNetVer!.?.??" (
				echo. Done^^!
                set "_bDotNet=.NET !_bNetVer! x64 Desktop Runtime exist"
            )
        )
    )
    if ["!_bDotNet!"]==[".NET %_bNetVer% unknown"] (
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    Sorry, could not complete automatic install                    %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%%_zDEFAULT%%_zWHITEonDARKCYAN% .NET %_bNetVer% x64 Desktop Runtime %_zDEFAULT%%_zBLACKonYELLOW% MUST be installed before continuing   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      Not 'Core' or 'ASP', and no other version will do^^!           %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%           .NET 9 and above are NOT compatible                     %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   NOTE: do not remove any already installed .net versions         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    goto 'https://dotnet.microsoft.com/en-us/download/dotnet/%_bNetVer%.0'  %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    and select the '.NET Desktop Runtime %_bNetVer%.?.?? Windows x64'       %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                   %_zDEFAULT%
        echo.
        pause
        REM dotnet --list-runtimes>"MODBUILDER\DOTNET.txt"
        REM echo.
        echo. --- FOR INFO: Currently installed versions are ---
        type "MODBUILDER\DOTNET.txt"
        echo.
        pause
        exit
    )
)
set "DotNet8=%_bDotNet%"

rem --------------   END: Installed DOTNET   ------------------------

rem --------------   Installed OS_1   -----------------------------
FOR /F "usebackq tokens=3,4,5" %%i IN (`REG query "hklm\software\microsoft\windows NT\CurrentVersion" /v ProductName`) DO (
    set "_bWinVer=%%i %%j %%k"
    set "_bWinNum=%%j"
)

Set "_bOS_bitness=64"
IF [%PROCESSOR_ARCHITECTURE%]==[x86] (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set "_bOS_bitness=32"
  )
  
set "_bCPU=%NUMBER_OF_PROCESSORS%"
set "_bMinCPU=3"

if %_bCPU% gtr %_bMinCPU% (
    set "_bAllowMapFileTreeCreator=Y"
    set "_bCreateMapFileTree=1"
)

REM if [%-MAPFILETREEFORCE%]==[Y] (
    set "_bAllowMapFileTreeCreator=Y"
REM )

REM for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "ProductName=%%~b"
REM for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion') do set "CurrentVersion=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "CurrentBuildHex=%%~b"

if not [%_bWinNum%]==[8] (
    for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v UBR') do set "UBRHEX=%%~b"
) else (
    set "UBRHEX=0"
)

set /a "_bCurrentBuildDec=%CurrentBuildHex%"
set /a "_bUBRDEC=%UBRHEX%"
rem --------------  end Installed OS_1   -----------------------------

rem **********************  start Active code page check  *************************
rem Active code page: 850, 437 are ok
rem chcp 65001
chcp >MODBUILDER\ActiveCodePage.txt

FOR /F "tokens=*" %%A IN ('CHCP') DO FOR %%B IN (%%~A) DO SET "_CodePage=%%B"

rem remove end dot for some version of German Windows XP and 7
if [%_CodePage:~-1%]==[.] (
    set "_CodePage=%_CodePage:~0,-1%"
)
if [%_CodePage%]==[65001] (
    echo.  %_zBLACKonYELLOW%                                                              %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%    **********  Bad Active Code Page Detected   *********     %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%           That will cause all kind of problems               %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%                                                              %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%    In Windows, goto Settings-^>Time and Language              %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%      - Click Region-^>Advanced date, time ^& regional settings %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%      - Click Region in the new window                        %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%      - Select tab Administrative                             %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%      - Click Change system locale                            %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%      - Untick "Beta: Use Unicode UTF-8..."                   %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%      - Click OK and Ok                                       %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%                                                              %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%  Terminating until corrected...                              %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%                                                              %_zDEFAULT%
    pause
    exit
)

echo.
echo. %_zWHITEonDARKCYAN% ^>^>^> Note: Please make sure no %_zDEFAULT%%_zINVERSE% 'accented characters' %_zDEFAULT%%_zWHITEonDARKCYAN% are in AMUMSS path %_zDEFAULT%
rem **********************  end Active code page check  *************************

rem change to 1250 can throw problems (tested with lMonk)
REM CHCP 1250 1>nul 2>nul

rem if it still exist, should not exist if AMUMSS was able to refresh the scripts
if exist "MODBUILDER\RefreshScripts.txt" (
	del /q "MODBUILDER\RefreshScripts.txt" 1>NUL 2>NUL
    if exist "ModScript\ModHelperScripts\Dictionary.lua" (
        if exist "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" (
            del /q "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" 1>NUL 2>NUL
        )
        ren "ModScript\ModHelperScripts\Dictionary.lua" "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" 1>NUL 2>NUL
    )
)

rem tell AMUMSS to refresh all scripts that need to be refreshed
rem but we do not want to do it every time
if [%-CreateUsefulUtilityScripts%]==[Y] (
    if not exist "ModScript\ModHelperScripts\Dictionary.lua" (
        echo.> "MODBUILDER\RefreshScripts.txt"
        if exist "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" (
            del /q "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" 1>NUL 2>NUL
        )
    )
)

rem *******************  output info to cmd  ***************************
echo.
if defined _updateDone (
    echo.%_zBRIGHTRED%  AMUMSS UPDATED to v%_mCurrentVersion%%_zDEFAULT%
) else (
    echo.%_zBRIGHTGREEN%  AMUMSS v%_mCurrentVersion%%_zDEFAULT%
)

echo.%_zBRIGHTGREEN%  BUILDMOD %_BMver% (%_bzrunM%)%_zDEFAULT%

if defined _bUsingAMM (
    if not defined _bUsingAMM_AUTO (
        echo.%_zBRIGHTGREEN%  Using AMM%_zDEFAULT%
    ) else (
        echo.%_zBRIGHTGREEN%  Using AMM with AUTO%_zDEFAULT%
    )
)

MODBUILDER\%_mLUA% -e print(_VERSION)>temp.txt
set /p _bVersionLua=<temp.txt
echo.%_zBRIGHTGREEN%  %_bVersionLua% custom version with lfs%_zDEFAULT%
Del /f /q "temp.txt" 1>NUL 2>NUL

if %_bCurrentBuildDec% GEQ 22000 (
    set "_bWinVer=%_bWinVer:10=11%"
)

if [%_bOS_bitness%]==[64] (
    echo.%_zBRIGHTGREEN%  %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
) else (
    echo.%_zBRIGHTGREEN%  %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
)

if defined _TestNet5 (
    echo.%_zBRIGHTGREEN%    %DotNet5%%_zDEFAULT%
)
if defined _TestNet6 (
    echo.%_zBRIGHTGREEN%    %DotNet6%%_zDEFAULT%
)
if defined _TestNet8 (
    echo.%_zBRIGHTGREEN%    %DotNet8%%_zDEFAULT%
)
MODBUILDER\%_mLUA% .\MODBUILDER\GetVersionInfo.lua ".\\" ".\\MODBUILDER\\" "Y"
set /p _bNMS_VERSIONID=<"MODBUILDER\NMS_versionId.txt" 1>NUL 2>NUL

REM echo. _bNMS_VERSIONID = [%_bNMS_VERSIONID%]

rem DO NOT REMOVE
set "_bB="

if defined _mVERBOSE set "_bB=BuildMod.bat:"

if defined _mVERBOSE (
    echo.
    echo.^>^>^>     In BuildMod.bat
)

echo.
echo.^>^>^> %_bB% Starting in "!CD!"

rem ******************  Test AMUMSS path for obvious problem  ***************
echo %CD%| FINDSTR /i /L /c:"appdata\\local\\temp\\" >MODBUILDER\StartingPath.txt
set /p _StartingPath=<MODBUILDER\StartingPath.txt
if not ["%_StartingPath%"]==[""] (
    echo.  %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
    echo.  %_zBLACKonYELLOW% **********  PLEASE correct your AMUMSS installation path   ********* %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%            Path should not be in: ["appdata\local\temp\"]            %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%            Use an install folder that is NOT an OS folder            %_zDEFAULT%
    echo.  %_zBLACKonYELLOW% Recommended location is root of a drive.  I:\AMUMSS, C:\AMUMSS, etc. %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%  Terminating until corrected...                                      %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
    pause
    exit
)
echo "%CD%"| FINDSTR /i "\\users\\.*\\Downloads\\\\" >MODBUILDER\StartingPath.txt
set /p _StartingPath=<MODBUILDER\StartingPath.txt
if not ["%_StartingPath%"]==[""] (
    echo.  %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
    echo.  %_zBLACKonYELLOW% **********  PLEASE correct your AMUMSS installation path   ********* %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%            Path should not be in: ["Users\*\Downloads\"]             %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%            Use an install folder that is NOT an OS folder            %_zDEFAULT%
    echo.  %_zBLACKonYELLOW% Recommended location is root of a drive.  I:\AMUMSS, C:\AMUMSS, etc. %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%  Terminating until corrected...                                      %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
    pause
    exit
)
echo %CD%| FINDSTR /i "\\users\\.*\\Desktop\\\\" >MODBUILDER\StartingPath.txt
set /p _StartingPath=<MODBUILDER\StartingPath.txt
if not ["%_StartingPath%"]==[""] (
    echo.  %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
    echo.  %_zBLACKonYELLOW% **********  PLEASE correct your AMUMSS installation path   ********* %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%            Path should not be in: ["Users\*\Desktop\"]               %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%            Use an install folder that is NOT an OS folder            %_zDEFAULT%
    echo.  %_zBLACKonYELLOW% Recommended location is root of a drive.  I:\AMUMSS, C:\AMUMSS, etc. %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%  Terminating until corrected...                                      %_zDEFAULT%
    echo.  %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
    pause
    exit
)
rem Del /f /q "MODBUILDER\StartingPath.txt" 1>NUL 2>NUL
rem ******************  END: Test AMUMSS path for obvious problem  ***************

rem remove old report.txt
Del /f /q "REPORT.txt" 1>NUL 2>NUL

rem we are using this now
Del /f /q "REPORT.lua" 1>NUL 2>NUL

if exist "REPORT.lua" (
	echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%             File "REPORT.lua" cannot be opened                %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%     It may be that a previous cmd window is still open...     %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%           probably from running:                              %_zDEFAULT%
	echo.  %_zBLACKonYELLOW% BUILDMOD / _Check_CONFLICTS_in_MODS / _Check_OUTDATED_in_MODS %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	echo.  %_zBLACKonYELLOW% Please terminate those previous cmd window^(s^) and re-try      %_zDEFAULT%
	echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	pause
	exit
)

rem **********************  start of NMS_FOLDER DISCOVERY section  *************************
rem try to find the NMS folder path
rem if the user gave a path, try to use it first
if exist ".\NMS_FOLDER.txt" (
	move /y "NMS_FOLDER.txt" ".\CONFIG\NMS_FOLDER.txt" 1>NUL 2>NUL
)

echo.
echo.^>^>^> %_bB% Checking Path to NMS_FOLDER...

rem *****************************************************
if not exist "CONFIG\NMS_FOLDER.txt" (
    rem we need to re-create it
    echo.
    echo.^>^>^>      Re-creating missing CONFIG\NMS_FOLDER.txt...
    copy /Y /B "MODBUILDER\NMS_FOLDER_BAK.txt" ".\CONFIG\NMS_FOLDER.txt" 1>NUL 2>NUL
)
rem *****************************************************

set /p _bNMS_FOLDER=<.\CONFIG\NMS_FOLDER.txt 1>NUL 2>NUL
echo !_bNMS_FOLDER!>test.txt
REM echo. A- [!_bNMS_FOLDER!]

set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"
REM echo. 0- [%_bNMS_PCBANKS_FOLDER%]

REM set "_bNMS_Binaries_FOLDER=%_bNMS_FOLDER%\Binaries\"

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
    copy /y "test.txt" ".\CONFIG\NMS_FOLDER.txt*" 1>NUL 2>NUL
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
    rem returns F:\Program Files (x86)\Steam
    rem or something like D:\Steam
    REM echo.   Found Steam install folder: !_bvalue!
    REM echo.   Looking for Libraries in !_bvalue!\steamapps\libraryfolders.vdf
    rem or in D:\Steam\steamapps\common\No Man's Sky
    
    ECHO !_bvalue!>test.txt
    set /p _bNMS_FOLDER=<test.txt
    set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"
    REM echo. 1- [!_bNMS_PCBANKS_FOLDER!]
    if exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
        echo.
        echo.%_bB% Found Path to NMS_FOLDER...
        copy /y "test.txt" ".\CONFIG\NMS_FOLDER.txt*" 1>NUL 2>NUL
    ) else (
        rem then NMS could be in a Steam Library folder
        ECHO !_bvalue!>test.txt
        echo.   Looking for Libraries in: [!_bvalue!]
        echo.
        
        Call :LuaEndedOkREMOVE
        set "location=bz15_GetNMSFolder.lua"
        MODBUILDER\%_mLUA% MODBUILDER\GetNMSFolder.lua "!_bvalue!" ".\\MODBUILDER\\"
        Call :LuaEndedOk
    )
)

set "_bREGKEY="
set "_bREGVAL="
set "_bvalue="

if not defined _bFoundNMS (
	set /p _bNMS_FOLDER=<.\CONFIG\NMS_FOLDER.txt
	set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"

	REM look for GamePass
	if not exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
		echo.   Looking for GAMEPASS No Man's Sky folder
		MODBUILDER\%_mLUA% .\MODBUILDER\GetGamePassPath.lua
	)
)

set "_bFoundNMS="

set /p _bNMS_FOLDER=<.\CONFIG\NMS_FOLDER.txt
set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"

if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
    echo.********************* PLEASE correct your path in CONFIG\NMS_FOLDER.txt, NMS game files not found ********************
    echo. Bad Path to: ["%_bNMS_PCBANKS_FOLDER%BankSignatures.bin"]
    echo. Found this PATH in [CONFIG\NMS_FOLDER.txt] "%_bNMS_FOLDER%"
    echo.%_zBRIGHTRED% ^>^>^> Your PATH in [CONFIG\NMS_FOLDER.txt] must be pointing to the folder containing 'GAMEDATA' %_zDEFAULT%
    echo.***** Terminating batch until corrected...
    pause
    exit
)

if not exist "%_bNMS_PCBANKS_FOLDER%NMSARC.audio.pak" (
    echo.********************* PLEASE correct your path in CONFIG\NMS_FOLDER.txt, NMS game files not found ********************
    echo. Bad Path to: ["%_bNMS_PCBANKS_FOLDER%NMSARC.audio.pak"]
    echo. Found this PATH in [CONFIG\NMS_FOLDER.txt] "%_bNMS_FOLDER%"
    echo.%_zBRIGHTRED% ^>^>^> Your PATH in [CONFIG\NMS_FOLDER.txt] must be pointing to the folder containing 'GAMEDATA' %_zDEFAULT%
    echo.***** Terminating batch until corrected...
    pause
    exit
) else (
    echo. %_zBLACKonYELLOW% Path to NMS_FOLDER is ^>^>^>%_zDEFAULT%%_zWHITEonDARKCYAN% GOOD %_zDEFAULT%%_zBLACKonYELLOW%^<^<^< game files found %_zDEFAULT%
)

rem cd /D "%~dp0"
cd /D "%CD%"

if defined _pause (
    echo B: AMUMSS: current directory: !CD!
    pause
)

echo.
echo.^>^>^> %_bB% Updating CONFIG\NMS_FOLDER.txt to "%_bNMS_FOLDER%"

if defined _DEBUG (
	echo. F: done tests
	pause
)

REM rem create a copy in case we need it in the future
REM copy /y ".\CONFIG\NMS_FOLDER.txt" "MODBUILDER\NMS_FOLDER_BAK.txt*" >NUL

Del /f /q "test.txt" 1>NUL 2>NUL
rem **********************  end of NMS_FOLDER DISCOVERY section  *************************

rem ************************************  SOME FOLDER preparation  ***********************
set "_bDoNotUseName=___DONOTUSE.txt"

rem ********  doing some cleanup that Delete_this.txt cannot do

Del /f /q "_Check_CONFLICTS_in_MODS.bat" 1>NUL 2>NUL
Del /f /q "_Check_OUTDATED.bat" 1>NUL 2>NUL

Del /f /q "MODBUILDER\AMUMSSMasterVersion.txt" 1>NUL 2>NUL
Del /f /q "EXML_NameHash_updater.bat" 1>NUL 2>NUL
Del /f /q "_MapFileMaker.exe" 1>NUL 2>NUL
Del /f /q "bzrun.bat" 1>NUL 2>NUL
Del /f /q "Log_file_cleaner.bat" 1>NUL 2>NUL
Del /f /q "Test_AMUMSS_install.bat" 1>NUL 2>NUL
Del /f /q "Test_CURL.bat" 1>NUL 2>NUL
Del /f /q "RemoveTrailingSpacesNon-empty.bat" 1>NUL 2>NUL

if not defined _mWbertro (
    Del /f /q "_Collapse_MODS.bat" 1>NUL 2>NUL
)

if exist ".\TOOLS\ModLuaLearningCollection\These scripts ARE for LEARNING ONLY" (
	rd /s /q ".\TOOLS\ModScriptCollection" 1>NUL 2>NUL
)

rem to move from old location to new location
if exist "NMS PCBANKS Explorer.ini" (
	move /Y "NMS PCBANKS Explorer.ini" ".\CONFIG\NMS PCBANKS Explorer.ini" 1>NUL 2>NUL
)

if exist ".\EXML_Helper" (
    CALL :Cleaning_EXML_Helper_OLD
)

if exist ".\DateTimeFormat.txt" (
	move /y "DateTimeFormat.txt" ".\CONFIG\DateTimeFormat.txt" 1>NUL 2>NUL
)

if exist ".\UNPACKED_DECOMPILED_PAKs" (
    move /y "UNPACKED_DECOMPILED_PAKs" ".\TOOLS\UNPACKED_DECOMPILED_PAKs" 1>NUL 2>NUL
)

if exist ".\NMSPE_Output" (
    move /y "NMSPE_Output" ".\TOOLS\NMSPE_Output" 1>NUL 2>NUL
)

if exist ".\Builds" (
    ren "Builds" "BuildHistory"
    move /y "BuildHistory" ".\ModBackups\BuildHistory" 1>NUL 2>NUL
)

if not exist ".\ModBackups" (
    mkdir ".\ModBackups\" 2>NUL
)

rem set "prefix=________________"
set /p prefix=<"MODBUILDER\ModBackups_prefix.txt"

if not exist ".\ModBackups\%prefix%BuildHistory" (
    mkdir ".\ModBackups\%prefix%BuildHistory" 2>NUL
)

if not exist ".\ModBackups\%prefix%IncrementalBuilds" (
    mkdir ".\ModBackups\%prefix%IncrementalBuilds\" 2>NUL
)

if not exist ".\CreatedMODS" (
    mkdir ".\CreatedMODS\" 2>NUL
)

if not exist ".\TOOLS\MODDER_Helper" (
    mkdir ".\TOOLS\MODDER_Helper\" 2>NUL
)

if exist ".\ModExtraFilesToInclude" (
    ren "ModExtraFilesToInclude" "GlobalMEFTI"
    move /y "GlobalMEFTI" ".\ModScript\GlobalMEFTI" 1>NUL 2>NUL
)

if exist "_ModScript_Manager.exe" (
    Del /f /q "_ModScript_Manager.exe" 1>NUL 2>NUL
)
rem ********  END: doing some cleanup that Delete_this.txt cannot do

if not exist ".\TOOLS\Test_Data\data" (
    mkdir ".\TOOLS\Test_Data\data" 2>NUL
)

set "_DisableFolder=Disabled scripts and paks"
if not exist ".\ModScript\%_DisableFolder%" (
    mkdir ".\ModScript\%_DisableFolder%" 2>NUL
)

set "_HelperScripts=ModHelperScripts"
if not exist ".\ModScript\%_HelperScripts%" (
    mkdir ".\ModScript\%_HelperScripts%" 2>NUL
)

if exist "ModScript\%_HelperScripts%\Dictionary_and_Images.lua" (
	del /f /q "ModScript\%_HelperScripts%\Dictionary_and_Images.lua" 1>NUL 2>NUL
)

REM if exist "ModScript\%_HelperScripts%\Dictionary.lua" (
	REM del /f /q "ModScript\%_HelperScripts%\Dictionary.lua" 1>NUL 2>NUL
REM )

if exist "ModScript\%_HelperScripts%\ImageDictionary.lua" (
	del /f /q "ModScript\%_HelperScripts%\ImageDictionary.lua" 1>NUL 2>NUL
)

REM if exist "MODBUILDER\Dictionary_and_Images.lua" (
    REM copy /Y /B "MODBUILDER\Dictionary_and_Images.lua" ".\ModScript\%_HelperScripts%\Dictionary_and_Images.lua" 1>NUL 2>NUL
	REM del /f /q "MODBUILDER\Dictionary_and_Images.lua" 1>NUL 2>NUL
REM )

REM if exist "MODBUILDER\Dictionary.lua" (
    REM copy /Y /B "MODBUILDER\Dictionary.lua" ".\ModScript\%_HelperScripts%\Dictionary.lua" 1>NUL 2>NUL
	REM del /f /q "MODBUILDER\Dictionary.lua" 1>NUL 2>NUL
REM )

REM if exist "MODBUILDER\ImageDictionary.lua" (
    REM copy /Y /B "MODBUILDER\ImageDictionary.lua" ".\ModScript\%_HelperScripts%\ImageDictionary.lua" 1>NUL 2>NUL	
	REM del /f /q "MODBUILDER\ImageDictionary.lua" 1>NUL 2>NUL
REM )

if not exist ".\CONFIG\Custom_MBINCompiler" (
    mkdir ".\CONFIG\Custom_MBINCompiler\" 2>NUL
)

if exist ".\TOOLS\EXML_Helper" (
    CALL :Cleaning_EXML_Helper_OLD
)

REM if not exist ".\TOOLS\MXML_Helper" (
	REM mkdir ".\TOOLS\MXML_Helper\" 2>NUL
REM )

if not exist ".\TOOLS\ModScriptCheck" (
    mkdir ".\TOOLS\ModScriptCheck\" 2>NUL
)

if not exist ".\TOOLS\SavedSections" (
    mkdir ".\TOOLS\SavedSections\" 2>NUL
)

if not exist ".\TOOLS\UNPACKED_DECOMPILED_PAKs" (
    mkdir ".\TOOLS\UNPACKED_DECOMPILED_PAKs\" 2>NUL
)

if not exist ".\MODBUILDER\_TEMP" (
    mkdir ".\MODBUILDER\_TEMP\" 2>NUL
)

rem *********************  reset MBINCompiler to needed version  ******************
rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

if defined _pause (
    echo C: MODBUILDER: current directory: !CD!
    pause
)

rem Letter required before the number, otherwise batch thinks it is a handle redirect
echo|set /p="IncrementalBuilds=%-IncrementalBuilds%">IncrementalBuilds.txt

if NOT [%-AutoUpdateMBinCompiler%]==[N] (
    set "_bCompilerExist=Y"
    if exist "CustomMBINCompiler.txt" (
        set "_bCompilerExist=N"
		Del /f /q "CustomMBINCompiler.txt" 1>NUL 2>NUL
    )
    if [!_bCompilerExist!]==[N] (
        Del /f /q "MBINCompiler.exe" 1>NUL 2>NUL
		Del /f /q "pak_list.txt" 1>NUL 2>NUL
    )
    REM echo.  Checking MBINCompiler in AutoUpdate mode...
    CALL :MBINCompilerUPDATE
    
    rem let's make sure the right type is the current version
    if exist "VersionPublic.txt" (
        copy /Y /B "MBINCompiler.public.exe" "MBINCompiler.exe" >nul
REM echo. PUBLIC flag
    ) else (
        copy /Y /B "MBINCompiler.latest.exe" "MBINCompiler.exe" >nul
REM echo. LATEST flag
    )
REM pause
)

if [%-AutoUpdateMBinCompiler%]==[N] (
    if not exist "CustomMBINCompiler.txt" (
		Del /f /q "pak_list.txt" 1>NUL 2>NUL
    )
	echo. >CustomMBINCompiler.txt
    if exist "..\CONFIG\Custom_MBINCompiler\MBINCompiler.exe" (
		copy /Y /B "..\CONFIG\Custom_MBINCompiler\MBINCompiler.exe" "MBINCompiler.exe" >nul
		copy /Y /B "MBINCompiler.exe" "MBINCompiler.public.exe" >nul
		copy /Y /B "MBINCompiler.exe" "MBINCompiler.latest.exe" >nul
	)
    rem MUST be handled by NMSPE, DO NOT USE THIS
	REM if exist "..\CONFIG\Custom_MBINCompiler\libMBIN.dll" (
		REM copy /Y /B "..\CONFIG\Custom_MBINCompiler\libMBIN.dll" "libMBIN.dll" >nul
		REM copy /Y /B "libMBIN.dll" "libMBIN.public.dll" >nul
		REM copy /Y /B "libMBIN.dll" "libMBIN.latest.dll" >nul
	REM )
)

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
    
	if not exist "CustomMBINCompiler.txt" (    
		echo.^>^>^> MBINCompiler 'latest' version: %_zBRIGHTGREEN%!_bMBINCompilerLatestVersion!%_zDEFAULT%
		echo.^>^>^> MBINCompiler 'public' version: %_zBRIGHTGREEN%!_bMBINCompilerPublicVersion!%_zDEFAULT%
    )
	
    rem RESET current Version
	set "_bMBINCompilerCurrentVersion="
    if exist "MBINCompilerCurrentVersion.txt" (
        set /p _bMBINCompilerCurrentVersion=<MBINCompilerCurrentVersion.txt
REM echo. _bMBINCompilerCurrentVersion = [!_bMBINCompilerCurrentVersion!]
    )
    
    REM echo. _bMBINCompilerCurrentVersion = [!_bMBINCompilerCurrentVersion!] _bMBINCompilerVersion = [!_bMBINCompilerVersion!]
    if not [!_bMBINCompilerCurrentVersion!]==[!_bMBINCompilerVersion!] (
        echo.
        echo.^>^>^> MBINCompiler version changed...
        echo.      - Cleaning MXML + MapFileTrees + SavedSections cache...
REM pause        
        CALL :Cleaning_TEMP_DECOMPILED
        CALL :Cleaning_MapFileTrees
        CALL :Cleaning_SavedSections
    )
    
    rem refresh current version
    Del /f /q "MBINCompilerCurrentVersion.txt" 1>NUL 2>NUL
    MBINCompiler.exe version -q >>MBINCompilerCurrentVersion.txt
) else (
    set "_bMBINCompilerVersion=UNKNOWN"
)

if exist FileStructureLevel.txt (
	set /p _previousFileStructureLevel=<FileStructureLevel.txt
)
if not [%_previousFileStructureLevel%]==[%-FileStructureLevel%] (
	echo.
	echo. ^>^>^> FileStructure Level changed to %-FileStructureLevel%
	CALL :Cleaning_MapFileTrees
)
REM save current level
echo|set /p "FileStructureLevel=%-FileStructureLevel%">FileStructureLevel.txt

rem ******   NOW IN AMUMSS folder   ********
cd ..

if defined _pause (
    echo D: AMUMSS: current directory: !CD!
    pause
)

REM rem *******************************************************************************
if not exist ".\CONFIG\OUTDATED_CheckList.txt" (
    copy /Y /B ".\MODBUILDER\OUTDATED_CheckList_template.txt" ".\CONFIG\OUTDATED_CheckList.txt" >nul
)

if not exist ".\TOOLS\MapFileTrees" (
    mkdir ".\TOOLS\MapFileTrees\" 2>NUL
)

if not exist ".\TOOLS\FileStructures" (
    mkdir ".\TOOLS\FileStructures\" 2>NUL
)

if not exist ".\TOOLS\REPORTS BACKUP" (
    mkdir ".\TOOLS\REPORTS_BACKUP\" 2>NUL
)

if exist ".\TOOLS\NMSPE_Output\EXMLFailList.txt" (
    Del /f /q ".\TOOLS\NMSPE_Output\EXMLFailList.txt" 1>NUL 2>NUL
)

if not exist "MODBUILDER\ResetMapFileTreeDone.txt" (
    rem to force the re-creation of all MapFileTree files
    rem when format changed
    Del /f /q ".\TOOLS\MapFileTrees\*.*" 1>NUL 2>NUL
    Del /f /q ".\TOOLS\FileStructures\*.*" 1>NUL 2>NUL
    ECHO. >.\MODBUILDER\ResetMapFileTreeDone.txt
) else (
    set /p _bResetMFT=<MODBUILDER\ResetMapFileTreeDone.txt
    if [!_bResetMFT!]==[RESET] (
        Del /f /q ".\TOOLS\MapFileTrees\*.*" 1>NUL 2>NUL
        Del /f /q ".\TOOLS\FileStructures\*.*" 1>NUL 2>NUL
        Del /f /q "MODBUILDER\ResetMapFileTreeDone.txt" 1>NUL 2>NUL
        ECHO. >.\MODBUILDER\ResetMapFileTreeDone.txt
        pause
    )
)

if not exist ".\ModScript\GlobalMEFTI" (
    mkdir ".\ModScript\GlobalMEFTI\" 2>NUL
)

if exist "MODBUILDER\Delete_this.txt" (
    FOR /F "delims=" %%G in (MODBUILDER\Delete_this.txt) do (
        if exist "%%G" (
            Del /f /q "%%G" 1>NUL 2>NUL
            RD "%%G" 1>NUL 2>NUL
        )
    )
    if not defined _mWbertro (
        Del /f /q "MODBUILDER\Delete_this.txt" 1>NUL 2>NUL
        rem show What's_new
        rem /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
        START "" "README\README-What's_new.txt"
    )
)

rem ******************  Check for BUILDMOD_AUTO.bat  ***********************************
if not exist "BUILDMOD_AUTO.bat" (
    rem we need to re-create it
    echo.
    echo.^>^>^>      Re-created missing BUILDMOD_AUTO.bat...
    copy /Y /B "MODBUILDER\buildmod_auto.backup" ".\BUILDMOD_AUTO.bat" >nul
)
REM if not exist "BUILDMOD_AMUMSS.bat" (
    REM rem we need to re-create it
    REM echo.
    REM echo.^>^>^>      Re-created missing BUILDMOD_AMUMSS.bat...
    REM copy /Y /B "MODBUILDER\buildmod_auto.backup" ".\BUILDMOD_AMUMSS.bat" >nul
REM )
rem *****************************************************

rem **********************  Check for updates  *******************************************
if not exist ".\MODBUILDER\UPDATE" (
    mkdir ".\MODBUILDER\UPDATE\" 2>NUL
)

REM if not defined _mWbertro goto :StepOverTest
REM echo.
REM echo. %_zBGintense%                    xxxxx TEST xxxxx                       %_zDEFAULT%
REM cd /D ".\ModScript"
REM for /D %%G in ("Disabled*") do (
    REM echo.                     found %%~nxG
REM )
REM cd /D "%~dp0"
REM cd /D "%CD%"

REM echo. %_zBGintense%                    xxxxx END TEST xxxxx                   %_zDEFAULT%
REM echo.
REM :StepOverTest
rem *****************************************************

rem *********************  NOW IN ModScript  *******************
cd ModScript

if defined _pause (
    echo E: ModScript: current directory: !CD!
    pause
)

REM set "command=cmd /c Del /f /q /s "*.luax" 1>NUL 2>NUL"
REM START "" /MIN "%command%"

rem removing old stuff
if exist EXTRACTED_PAK CALL :Cleaning_EXTRACTED_PAK
if exist EXMLFILES_PAK CALL :Cleaning_EXMLFILES_PAK
if exist EXMLFILES_CURRENT CALL :Cleaning_EXMLFILES_CURRENT
Del /f /q /s "REPORT_*.txt" 1>NUL 2>NUL

rem *********************  NOW IN MODBUILDER folder  *******************
cd ../MODBUILDER

if defined _pause (
    echo F: MODBUILDER: current directory: !CD!
    pause
)

set "location=bz18_START_PAK_LISTsCREATION"
REM echo. %time% %location%

CALL :PAK_LISTsCREATION

set "location=bz18_END_PAK_LISTsCREATION"
REM echo. %time% %location%

rem *********************  NOW IN AMUMSS folder  *******************
cd ..

if defined _pause (
    echo G: AMUMSS: current directory: !CD!
    pause
)

rem ------------ CLEANLOG --------------------------------
set "_CLEANLOG=%-CLEANLOG%"
if [%-CLEANLOG%]==[] goto :CLEANLOG
if [%-CLEANLOG%]==[Y] goto :CLEANLOG
if [%-CLEANLOG%]==[N] goto :NOCLEANLOG

echo.
echo.==^> BAD OPTION VALUE for '-CLEANLOG' [%-CLEANLOG%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause
goto :CLEANLOG

:NOCLEANLOG
set "_CLEANLOG=N"
goto :ENDCLEANLOG

:CLEANLOG
set "_CLEANLOG=Y"
:ENDCLEANLOG
rem ------------ END: CLEANLOG --------------------------------

rem ------------ SOUND --------------------------------
set "_SOUND=%-SOUND%"
if [%_SOUND%]==[] goto :SOUND
if [%_SOUND%]==[Y] goto :SOUND
if [%_SOUND%]==[N] goto :NOSOUND

echo.
echo.==^> BAD OPTION VALUE for '-SOUND' [%_SOUND%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause
goto :SOUND

:NOSOUND
set "_SOUND=N"
goto :ENDSOUND

:SOUND
set "_SOUND=Y"
:ENDSOUND
rem ------------ END: SOUND --------------------------------

rem ------------ DEV_MODE --------------------------------
set "_DEV_MODE=%-DEV_MODE%"
if [%-DEV_MODE%]==[ASK] goto :ASK_DEV_MODE
if [%-DEV_MODE%]==[] goto :ASK_DEV_MODE
if [%-DEV_MODE%]==[F] goto :DEV_MODE
if [%-DEV_MODE%]==[D] goto :DEV_MODE
if [%-DEV_MODE%]==[L] goto :DEV_MODE

echo.
echo.==^> BAD OPTION VALUE for '-DEV_MODE' [%-DEV_MODE%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause

:ASK_DEV_MODE
echo.
echo.^>^>^> NOTE: the choice you make here does not affect the content of Report.lua
echo.                 it only affects the content of this current cmd window and log.lua
echo.    %_zBRIGHTGREEN%FULL%_zDEFAULT%: generate ALL 'Info' and 'helper' files
echo.    %_zBRIGHTGREEN%DEV %_zDEFAULT%: same as FULL mode ^(but may limit output in cmd^)
echo.    %_zBRIGHTGREEN%LEAN%_zDEFAULT%: ONLY generate minimal 'Info' and files necessary to produce the mods
echo.
CHOICE /c:FDL /m " %_zBLACKonYELLOW% ??? Do you want to use AMUMSS in [F]ULL, [D]EV or [L]EAN mode %_zDEFAULT%"
if %ERRORLEVEL% EQU 3 set "_DEV_MODE=L"
if %ERRORLEVEL% EQU 2 set "_DEV_MODE=D"
if %ERRORLEVEL% EQU 1 set "_DEV_MODE=F"

:DEV_MODE
call :DEV_MODE_INFO
rem ------------ END: DEV_MODE --------------------------------

rem ------------ GameVersion_1 --------------------------------
set "_GameVersion=%-GameVersion%"
if [%-GameVersion%]==[ASK] goto :ASK_GameVersion
if [%-GameVersion%]==[] goto :ASK_GameVersion
if [%-GameVersion%]==[P] goto :GameVersionDone
if [%-GameVersion%]==[E] goto :GameVersionDone

echo.
echo.==^> BAD OPTION VALUE for '-GameVersion' [%-GameVersion%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause

:ASK_GameVersion
echo.
if exist ".\MODBUILDER\VersionPublic.txt" (
    echo. User previously reported using NMS '%_zBRIGHTGREEN%Public%_zDEFAULT%' version
) else (
    echo. User previously reported using NMS '%_zBRIGHTGREEN%Experimental%_zDEFAULT%' version
)

CHOICE /c:PE /m " %_zBLACKonYELLOW% ??? IS your NMS game version [P]ublic or [E]xperimental %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 set "_GameVersion=E"
if %ERRORLEVEL% EQU 1 set "_GameVersion=P"

:GameVersionDone
rem ------------ END: GameVersion_1 --------------------------------

rem ********************************  end SOME FOLDER preparation  ***********************
set "_INFO=^[INFO] "
set "_INFO="

rem ----------------------------------  Start REPORTing  -----------------------------------------------
echo|set /p=!_bDateTimeStart!>>"REPORT.lua" & echo.>>"REPORT.lua"
echo.>>"REPORT.lua"

if defined _updateDone (
    echo|set /p="%_INFO% AMUMSS UPDATED to v%_mCurrentVersion%">>"REPORT.lua" & echo.>>"REPORT.lua"
) else (
    echo|set /p="%_INFO% AMUMSS v%_mCurrentVersion%">>"REPORT.lua" & echo.>>"REPORT.lua"
)

echo|set /p="%_INFO% BUILDMOD %_BMver% (%_bzrunM%)">>"REPORT.lua" & echo.>>"REPORT.lua"

if defined _bUsingAMM (
    if not defined _bUsingAMM_AUTO (
        echo|set /p="%_INFO% Using AMM">>"REPORT.lua" & echo.>>"REPORT.lua"
    ) else (
        echo|set /p="%_INFO% Using AMM with AUTO">>"REPORT.lua" & echo.>>"REPORT.lua"
    )
)

echo|set /p="%_INFO% using %_bVersionLua% custom version with lfs">>"REPORT.lua" & echo.>>"REPORT.lua"

if [%_bOS_bitness%]==[64] (
    echo|set /p="%_INFO% on %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs (cp%_CodePage%)">>"REPORT.lua" & echo.>>"REPORT.lua"
) else (
    echo|set /p="%_INFO% on %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs (cp%_CodePage%)">>"REPORT.lua" & echo.>>"REPORT.lua"
)

if defined _TestNet5 (
    echo|set /p="%_INFO% %DotNet5%">>"REPORT.lua" & echo.>>"REPORT.lua"
)
if defined _TestNet6 (
    echo|set /p="%_INFO% %DotNet6%">>"REPORT.lua" & echo.>>"REPORT.lua"
)
if defined _TestNet8 (
    echo|set /p="%_INFO% %DotNet8%">>"REPORT.lua" & echo.>>"REPORT.lua"
)
REM echo. _bNMS_VERSIONID = [%_bNMS_VERSIONID%]
REM echo on
if [!_bNMS_VERSIONID!]==[not found] (
    rem try again
    MODBUILDER\%_mLUA% .\MODBUILDER\GetVersionInfo.lua ".\\" ".\\MODBUILDER\\" "Y"
    set /p _bNMS_VERSIONID=<"MODBUILDER\NMS_versionId.txt" 1>NUL 2>NUL
)
REM echo off
REM pause
REM exit

if exist "MODBUILDER\MBINCompiler.exe" (
    Del /f /q "MODBUILDER\MBINCompilerVersion.txt" 1>NUL 2>NUL
    MODBUILDER\MBINCompiler.exe version -q >>MODBUILDER\MBINCompilerVersion.txt
    set /p _bMBINCompilerVersion=<MODBUILDER\MBINCompilerVersion.txt
)

if exist ".\MODBUILDER\VersionPublic.txt" (
    if exist "MODBUILDER\MBINCompiler.public.exe" (
        Del /f /q "MODBUILDER\MBINCompilerPublicVersion.txt" 1>NUL 2>NUL
        MODBUILDER\MBINCompiler.public.exe version -q >>MODBUILDER\MBINCompilerPublicVersion.txt
        set /p _bMBINCompilerPublicVersion=<MODBUILDER\MBINCompilerPublicVersion.txt
    )
    if not [!_bMBINCompilerPublicVersion!]==[!_bMBINCompilerVersion!] (
        echo|set /p="User previously reported using NMS 'Experimental' with version %_bNMS_VERSIONID%">>"REPORT.lua" & echo.>>"REPORT.lua"
    ) else (
        echo|set /p="User previously reported using NMS 'Public' with version %_bNMS_VERSIONID%">>"REPORT.lua" & echo.>>"REPORT.lua"
    )
) else (
    if exist "MODBUILDER\MBINCompiler.latest.exe" (
        Del /f /q "MODBUILDER\MBINCompilerLatestVersion.txt" 1>NUL 2>NUL
        MODBUILDER\MBINCompiler.latest.exe version -q >>MODBUILDER\MBINCompilerLatestVersion.txt
        set /p _bMBINCompilerLatestVersion=<MODBUILDER\MBINCompilerLatestVersion.txt
    )
    if not [!_bMBINCompilerLatestVersion!]==[!_bMBINCompilerVersion!] (
        echo|set /p="User previously reported using NMS 'Public' with version %_bNMS_VERSIONID%">>"REPORT.lua" & echo.>>"REPORT.lua"
    ) else (
        echo|set /p="User previously reported using NMS 'Experimental' with version %_bNMS_VERSIONID%">>"REPORT.lua" & echo.>>"REPORT.lua"
    )
)

rem ******************  GameVersion_2  ********************************
rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

if defined _pause (
    echo H: MODBUILDER: current directory: !CD!
    pause
)

if exist "MBINCompiler.exe" (
    Del /f /q "MBINCompilerVersion.txt" 1>NUL 2>NUL
    MBINCompiler.exe version -q >>MBINCompilerVersion.txt
    set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
)

if NOT [%-AutoUpdateMBinCompiler%]==[N] (
    if [!_GameVersion!]==[P] (
        echo.^>^>^> User declared using NMS '%_zBRIGHTGREEN%Public%_zDEFAULT%' version
        echo|set /p="User declared using NMS 'Public' with version %_bNMS_VERSIONID%">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        rem this is NEVER changed, except here
		echo. >DeclaredVersionPublic.txt
		rem this can be changed by LoadAndExecuteModScript.lua
        echo. >VersionPublic.txt
        REM echo. created PUBLIC flag
    ) else (
        echo.^>^>^> User declared using NMS '%_zBRIGHTGREEN%Experimental%_zDEFAULT%' version
        echo|set /p="User declared using NMS 'Experimental' with version %_bNMS_VERSIONID%">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        Del /f /q "DeclaredVersionPublic.txt" 1>NUL 2>NUL
        Del /f /q "VersionPublic.txt" 1>NUL 2>NUL
        REM echo. created LATEST flag
    )
    
    CALL :SWITCH_COMPILER
) else (
    echo.^>^>^> %gcATTENTION% MBINCompiler AutoUpdate disabled %_zDEFAULT% Using '%_zBRIGHTGREEN%custom%_zDEFAULT%' version: %_zBRIGHTGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
    echo|set /p="<<< MBINCompiler AutoUpdate disabled >>> Using 'custom' version: %_bMBINCompilerVersion%">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
)

REM pause

if exist "MBINCompiler.exe" (
    set /p _bMBINCompilerCurrentVersion=<MBINCompilerCurrentVersion.txt
    REM echo. _bMBINCompilerCurrentVersion = [!_bMBINCompilerCurrentVersion!] _bMBINCompilerVersion = [!_bMBINCompilerVersion!]
    if not [!_bMBINCompilerCurrentVersion!]==[!_bMBINCompilerVersion!] (
        echo.      - Cleaning MXML + MapFileTrees + SavedSections cache...
        echo|set /p="%_INFO% Cleaned EXML + MapFileTrees + SavedSections cache">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
REM pause        
        CALL :Cleaning_TEMP_DECOMPILED
        CALL :Cleaning_MapFileTrees
        CALL :Cleaning_SavedSections
    )
    
    rem refresh current version
    Del /f /q "MBINCompilerCurrentVersion.txt" 1>NUL 2>NUL
    MBINCompiler.exe version -q >>MBINCompilerCurrentVersion.txt

    rem update array_data.txt
    if exist "DeclaredVersionPublic.txt" (
        copy /Y /B "libMBIN.public.dll" ".\ArrayInfo\libMBIN.dll" >nul        
    ) else (
        copy /Y /B "libMBIN.latest.dll" ".\ArrayInfo\libMBIN.dll" >nul        
    )
    call ArrayInfo.bat
    
) else (
    echo.%gcERROR%^>^>^> [ERROR] MBINCompiler.exe is missing in MODBUILDER folder, we cannot continue until corrected%_zDEFAULT%
    echo|set /p="[ERROR] MBINCompiler.exe is missing in MODBUILDER folder, we cannot continue until corrected">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    echo.>>"..\REPORT.lua"
    pause
    exit
)

rem ******   NOW IN AMUMSS folder   ********
cd ..

if defined _pause (
    echo I: AMUMSS: current directory: !CD!
    pause
)

echo|set /p="%_INFO% Now with MBINCompiler v%_bMBINCompilerCurrentVersion%">>"REPORT.lua" & echo.>>"REPORT.lua"

echo.>>"REPORT.lua"
echo|set /p="^>^>^> Starting in '!CD!'">>"REPORT.lua" & echo.>>"REPORT.lua"
echo|set /p=">>> Updating CONFIG\NMS_FOLDER.txt to %_bNMS_FOLDER%">>"REPORT.lua" & echo.>>"REPORT.lua"

REM ADDED message to check 'open files' in xxx preventing AMUMSS to work
REM echo.
REM echo.%_zBRIGHTRED% ============================================================================%_zDEFAULT%
REM echo. %_zINVERSE%[NOTE] EXCEPT when saying: 'Opening User Lua Script, Please wait...'        %_zDEFAULT%
REM echo. %_zINVERSE%       When AMUMSS seems to freeze and stop processing for ^> 60 seconds     %_zDEFAULT%
REM echo. %_zINVERSE%       probably means it cannot delete some files in a working directories. %_zDEFAULT%
REM echo. %_zINVERSE%    Please 'close' all AMUMSS files you have opened in other apps           %_zDEFAULT%
REM echo. %_zINVERSE%   (Files opened in Notepad++, for example, will not cause this problem)    %_zDEFAULT%
REM echo.%_zBRIGHTRED% ============================================================================%_zDEFAULT%
rem -------------------------------  end Start REPORTing  -----------------------------------------------

rem Windows accepts a max of 260 char for drive/path/filename/ext length
rem NMS accepts only 118 char + .pak = 114
rem we need to leave room for '_(9)' so 110-4 = 106 + .pak
rem using 75 to allow a bit of slack
rem NMS accepts only 122 char for MODS sub-folders
SET "_bMaxPakNameLength=55"

REM if %_bNumberScripts% EQU 0 (
    REM echo.
    REM echo. %_zBLACKonYELLOW% ^>^>^>   [INFO] NO user .lua Mod Script found in ModScript... %_zDEFAULT%
    REM echo.              You may want to put some .lua Mod script in the ModScript folder and retry...
    
    REM echo|set /p="%_INFO% NO user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
    REM echo.>>"REPORT.lua"
    
    REM set _bNoScript=y
REM ) else (
    REM SET _bBuildMODpak=y
    REM REM echo.  Trying to clean TOOLS\MXML_Helper folder...
    REM CALL :Cleaning_MXML_Helper
REM )
REM rem --------------  end Check # of scripts present ------------------------------

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

if defined _pause (
    echo J: MODBUILDER: current directory: !CD!
    pause
)

if [%-MAPFILETREE%]==[TXT] goto :SelectMapFileTree
if [%-MAPFILETREE%]==[TXTPLUS] goto :SelectMapFileTree
if [%-MAPFILETREE%]==[LUA] goto :SelectMapFileTree
if [%-MAPFILETREE%]==[LUAPLUS] goto :SelectMapFileTree

echo.==^> BAD OPTION VALUE for '-MAPFILETREE' [%-MAPFILETREE%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions

REM set to DEFAULT
set "-MAPFILETREE=LUA"

:SelectMapFileTree
rem Used by CreateMapFileTree.lua to select type of output file
Del /f /q USE_TXT_MAPFILETREE.txt 1>NUL 2>NUL
Del /f /q USE_LUA_MAPFILETREE.txt 1>NUL 2>NUL
Del /f /q USE_TXTPLUS_MAPFILETREE.txt 1>NUL 2>NUL
Del /f /q USE_LUAPLUS_MAPFILETREE.txt 1>NUL 2>NUL

if [%-MAPFILETREE%]==[TXT] ECHO >USE_TXT_MAPFILETREE.txt
if [%-MAPFILETREE%]==[TXTPLUS] ECHO >USE_TXT_MAPFILETREE.txt
if [%-MAPFILETREE%]==[TXTPLUS] ECHO >USE_TXTPLUS_MAPFILETREE.txt
if [%-MAPFILETREE%]==[LUA] ECHO >USE_LUA_MAPFILETREE.txt
if [%-MAPFILETREE%]==[LUAPLUS] ECHO >USE_LUA_MAPFILETREE.txt
if [%-MAPFILETREE%]==[LUAPLUS] ECHO >USE_LUAPLUS_MAPFILETREE.txt

Del /f /q MapFileTreeRunner.lua 1>NUL 2>NUL
Del /f /q MapFileTreeCreatorRun.txt 1>NUL 2>NUL
Del /f /q MapFileTreeRequested.txt 1>NUL 2>NUL

del /f /q LoadScriptAndFilenamesERROR.txt 1>NUL 2>NUL

del /f /q MOD_BATCHNAME.txt 1>NUL 2>NUL
echo|set /p="">MOD_BATCHNAME.txt

del /f /q MBIN_PAKS.txt 1>NUL 2>NUL
echo|set /p="">MBIN_PAKS.txt
echo.>>"MBIN_PAKS.txt"

del /f /q ModScript_pak_list.txt 1>NUL 2>NUL
echo|set /p="">ModScript_pak_list.txt

del /f /q ModScript_pakContent_list.txt 1>NUL 2>NUL
echo|set /p="">ModScript_pakContent_list.txt

del /f /q MODS_pak_list.txt 1>NUL 2>NUL
echo|set /p="">MODS_pak_list.txt

del /f /q ModScript_MBIN_list.txt 1>NUL 2>NUL
echo|set /p="">ModScript_MBIN_list.txt

Del /f /q "FailedScriptList.txt" 1>NUL 2>NUL

rem ******   NOW IN AMUMSS folder   ********
cd ..

if defined _pause (
    echo K: AMUMSS: current directory: !CD!
    pause
)

rem ------------ Test IncludeLuaScriptInPak for good option value --------------------------------
if [%-IncludeLuaScriptInPak%]==[ASK] goto :TestOptionValueDone
if [%-IncludeLuaScriptInPak%]==[] goto :SetToY
if [%-IncludeLuaScriptInPak%]==[Y] goto :TestOptionValueDone
if [%-IncludeLuaScriptInPak%]==[N] goto :TestOptionValueDone

echo.
echo.==^> BAD OPTION VALUE for '-IncludeLuaScriptInPak' [%-IncludeLuaScriptInPak%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause
:SetToY
set "-IncludeLuaScriptInPak=Y"
:TestOptionValueDone
rem ------------ END: Test IncludeLuaScriptInPak for good option value --------------------------------

rem ------------ Test GUIF_AllowRequests for good option value --------------------------------
if [%-GUIF_AllowRequests%]==[ASK] goto :TestOptionValueDone1
if [%-GUIF_AllowRequests%]==[] goto :SetToY_2
if [%-GUIF_AllowRequests%]==[Y] goto :TestOptionValueDone1
if [%-GUIF_AllowRequests%]==[N] goto :TestOptionValueDone1

echo.
echo.==^> BAD OPTION VALUE for '-GUIF_AllowRequests' [%-GUIF_AllowRequests%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause
:SetToY_2
set "-GUIF_AllowRequests=Y"
:TestOptionValueDone1
rem ------------ END: Test GUIF_AllowRequests for good option value --------------------------------

rem --------------  Check # of PAKs or MBINs present ------------------------------
rem ******   NOW IN MODBUILDER folder   ********
cd MODBUILDER

if defined _pause (
    echo L: MODBUILDER: current directory: !CD!
    pause
)

if exist "RefreshScripts.txt" (
	REM echo.
	REM echo. %_zBLACKonYELLOW% ^>^>^>   [INFO] AUTO-Refreshing useful scripts, one moment... %_zDEFAULT%

	rem ###################################################################
	rem --------  processing useful scripts -------------
	rem ###################################################################
					REM rem reset counter of processed scripts
					REM echo|set /p="">ScriptCounter.txt
					
					set "location=bzAUTO_START_LoadAndExecuteModScript.lua"
					REM echo. %time% %location%
					
					if defined _mDEV (
						echo. %gcWARNING% LOADING LoadAndExecuteModScript_DEV %_zDEFAULT%
					)
					
					del exitCode.txt 1>NUL 2>NUL
                    
					Call :LuaEndedOkREMOVE
                    if exist LoadAndExecuteModScript_DEV.lua (
                        rem %_mLUA% LoadAndExecuteModScript_DEV.lua "DONOTCOPYTOMOD" "..\TOOLS\Useful Utility Scripts\Lang_Shrinker.lua" "..\TOOLS\Useful Utility Scripts\MakeDictionary.lua"
                        %_mLUA% LoadAndExecuteModScript_DEV.lua "DONOTCOPYTOMOD" "..\TOOLS\Useful Utility Scripts\MakeDictionary.lua"
                    ) else (
                        rem %_mLUA% LoadAndExecuteModScript.lua "DONOTCOPYTOMOD" "..\TOOLS\Useful Utility Scripts\Lang_Shrinker.lua" "..\TOOLS\Useful Utility Scripts\MakeDictionary.lua"
                        %_mLUA% LoadAndExecuteModScript.lua "DONOTCOPYTOMOD" "..\TOOLS\Useful Utility Scripts\MakeDictionary.lua"
                    )

                    if exist "exitCode.txt" (
                        set /p exitCode=<"exitCode.txt"
                    )
                    REM echo exitCode = [!exitCode!]
					Call :LuaEndedOk
					
                    if [!exitCode!]==[BADPAKTYPE] (
                        goto :eof
                    )
                    if [!exitCode!]==[BADAMUMSSFOLDER] (
                        goto :eof
                    )

					set "location=bzAUTO_END_LoadAndExecuteModScript.lua"
					REM echo. %time% %location%
					
					REM rem get # of processed script
					REM SET /p _bScriptCounter=<ScriptCounter.txt
					
					IF EXIST "LoadScriptAndFilenamesERROR.txt" (
						set "_bErrorLoadingScript=y"
					)
					
					REM CALL :DOPAUSE
					IF DEFINED _bErrorLoadingScript (
						echo|set /p="    [ENDED THIS SCRIPT PROCESSING] =========================================================">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
						echo.
					)
					rem set "_bErrorLoadingScript="
					del /f /q LoadScriptAndFilenamesERROR.txt 1>NUL 2>NUL
                    
                    rem testing if this makes the access errors go away or reduce them
                    ping -n 10 127.0.0.1>nul
    
	rem ##########################################################################
	rem --------  END: processing useful scripts -------------
	rem ##########################################################################
)

echo.
echo.^>^>^> Inspecting Modscript...

set "_uOldMBINCompilerFlag=N"
SET "_uOldMBIN=N"

SET "_bGNumberFiles=0"
SET "_bGNumberFilesDecompiled=0"
SET "_bGNumberFilesMissing=0"
SET "_bGNumberFilesNoVersionInfo=0"
SET "_bNumberFilesCouldNotDecompile=0"
SET "_bGNumScriptsInPak=0"

REM for Check mod Conflicts
SET "_bGConflictLines=0"

set "location=bz44_START_SearchModScriptForMultiFileExt.lua"
REM echo. %time% %location%

REM echo. Testing Modscript for ...
Call :LuaEndedOkREMOVE
%_mLUA% SearchModScriptForMultiFileExt.lua ".MBIN,.EXML,.MXML,.lua,.pak" "" "TooDeep" "" "" "true"
rem cd ..
for /f "tokens=2,4,6,8,10 delims==," %%G in (modscriptContent.txt) do (
    set "_MBIN=%%G"
    set "_EXML=%%H"
    set "_MXML=%%I"
    set "_LUA=%%J"
    set "_PAK=%%K"
)

SET /A "_bNumberScripts=%_LUA%"
SET /A "_bNumberPAKs=%_PAK%"
SET /A "_bNumberMBINs=%_MBIN%"
SET /A "_bNumberEXMLs=%_EXML%"
SET /A "_bNumberMXMLs=%_MXML%"

if exist "..\MODSCRIPT\___DONOTUSE.txt" (
    SET /A "_bNumberPAKs=0"
    SET /A "_bNumberMBINs=0"
    SET /A "_bNumberEXMLs=0"
    SET /A "_bNumberMXMLs=0"
)

REM echo. YYY_=_AAA _bNumberScripts = %_bNumberScripts%
REM echo. YYY_=_AAA    _bNumberPAKs = %_bNumberPAKs%
REM echo. YYY_=_AAA   _bNumberMBINs = %_bNumberMBINs%
REM echo. YYY_=_AAA   _bNumberEXMLs = %_bNumberEXMLs%
REM echo. YYY_=_AAA   _bNumberMXMLs = %_bNumberMXMLs%

    REM ---- FOR TESTING ONLY
	REM %_mLUA% SearchModScriptForFileExt.lua ".lua"
    REM SET "_bResult=!ERRORLEVEL!"
    REM SET /A "_xNumberScripts=_bResult"
	REM echo. YYY_=_AAA _xNumberScripts = %_xNumberScripts%
REM pause

set "location=bz44___END_SearchModScriptForMultiFileExt.lua"
REM echo. %time% %location%

rem ******   NOW IN AMUMSS folder   ********
cd ..

if defined _pause (
    echo M: AMUMSS: current directory: !CD!
    pause
)
if %_bNumberScripts% EQU 0 (
    echo.
    echo. %_zBLACKonYELLOW% ^>^>^>   [INFO] NO user .lua Mod Script found in ModScript... %_zDEFAULT%
    echo.              You may want to put some .lua Mod script in the ModScript folder and retry...
    
    echo|set /p="%_INFO% NO user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
    echo.>>"REPORT.lua"
    
    set "_bNoScript=y"
) else (
    SET "_bBuildMODpak=y"
    REM echo.  Trying to clean TOOLS\MXML_Helper folder...
    REM CALL :Cleaning_MXML_Helper
)
rem --------------  end Check # of scripts present ------------------------------

if %_bNumberEXMLs% GTR 0 (
    SET "_bEXML=Y"
)

if %_bNumberMXMLs% GTR 0 (
    SET "_bMXML=Y"
)

if %_bNumberPAKs% GTR 0 (
    SET "_bPAK_MBIN=Y"
)

if %_bNumberMBINs% GTR 0 (
	SET "_bPAK_MBIN=Y"
)

rem here if _bPAK_MBIN is defined, at least one PAK or MBIN is present in ModScript

            REM rem *********************  NOW IN MODBUILDER  *******************
            REM cd MODBUILDER
            REM REM rem *************  Check MBINCompiler update  *********************
            
            REM REM REM echo.  Checking MBINCompiler if in AutoUpdate mode...
            REM REM if NOT [%-AutoUpdateMBinCompiler%]==[N] (
                REM REM CALL :MBINCompilerUPDATE
            REM REM )
            
            REM rem ******   NOW IN AMUMSS folder   ********
            REM cd ..
            
rem default = INDIVIDUAL mod
SET "_bCOMBINE_MOD_TYPE=0"

REM rem default = type of individual mod: PLAIN
REM SET "_bINDIVIDUAL_MODS=1"

rem default = NONE copied to MODS
SET "_bCOPYtoNMS=NONE"

if DEFINED _bMXML (
    if %_bNumberMXMLs% GTR 1 (
        echo.
        echo. %_zBLACKonYELLOW% ^>^>^> Detected %_bNumberMXMLs% user MXMLs in ModScript... %_zDEFAULT%
        echo.   %_zBRIGHTGREEN%If these MXMLs have the right path, they will be used by all associated script^(s^)%_zDEFAULT%
        echo.
        
        echo|set /p="%_INFO% Detected %_bNumberMXMLs% user MXMLs in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
    ) else (
        if %_bNumberMXMLs% GTR 0 (
            echo.
            echo. %_zBLACKonYELLOW% ^>^>^> Detected 1 user MXML in ModScript... %_zDEFAULT%
            echo.   %_zBRIGHTGREEN%If this MXML has the right path, it will be used by all associated script^(s^)%_zDEFAULT%
            echo.
            
            echo|set /p="%_INFO% Detected 1 user MXML in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
        )
    )
)

if DEFINED _bPAK_MBIN (
    set "location=bz34"
    REM echo. %time% %location%
REM echo. FFF_=_FFF_0 _bPAK_MBIN = [%_bPAK_MBIN%]
    if %_bNumberScripts% GTR 0 (
        CALL :CHECK_ExtraFilesToInclude
    )
    
    rem *********************  NOW IN MODBUILDER folder  *******************
    cd MODBUILDER
    
    if defined _pause (
        echo N: MODBUILDER: current directory: !CD!
        pause
    )
    
    CALL :CONFLICTDETECTION
    REM echo _bCheckMODSconflicts = !_bCheckMODSconflicts!
    
    if !_bCheckMODSconflicts! EQU 1 (
        REM get list of paks in NMS MODS folder > MODS_pak_list.txt
        CALL PSARC_LIST_PAKS_MODS.BAT
    )
    if !_bCheckMODSconflicts! EQU 3 (
        REM get list of paks in NMS MODS folder > MODS_pak_list.txt
        CALL PSARC_LIST_PAKS_MODS.BAT
    )
    
    rem ******   NOW IN AMUMSS folder   ********
    cd ..

    if defined _pause (
        echo O: AMUMSS: current directory: !CD!
        pause
    )
    
    echo.
    echo.-----------------------------------------------------------
    if %_bNumberPAKs% GTR 1 (
        echo. %_zBLACKonYELLOW% ^>^>^> Detected %_bNumberPAKs% user PAKs in ModScript... %_zDEFAULT%
        echo.
        
        echo|set /p="%_INFO% Detected %_bNumberPAKs% user PAKs in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
    ) else (
        if %_bNumberPAKs% GTR 0 (
            echo. %_zBLACKonYELLOW% ^>^>^> Detected 1 user PAK in ModScript... %_zDEFAULT%
            echo.
            
            echo|set /p="%_INFO% Detected 1 user PAK in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
        )
    )
	
    if %_bNumberMBINs% GTR 1 (
        echo. %_zBLACKonYELLOW% ^>^>^> Detected %_bNumberMBINs% user MBINs in ModScript... %_zDEFAULT%
        echo.
        
        echo|set /p="%_INFO% Detected %_bNumberMBINs% user MBINs in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
    ) else (
        if %_bNumberMBINs% GTR 0 (
            echo. %_zBLACKonYELLOW% ^>^>^> Detected 1 user MBIN in ModScript... %_zDEFAULT%
            echo.
            
            echo|set /p="%_INFO% Detected 1 user MBIN in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
        )
    )
    
    rem *********************  NOW IN MODBUILDER  *******************
    cd MODBUILDER

    if defined _pause (
        echo P: MODBUILDER: current directory: !CD!
        pause
    )
    
    rem ****************  Get list of paks in ModScript  ****************
    if %_bNumberPAKs% GTR 0 (
        CALL PSARC_LIST_ModScriptPAKS.BAT
        echo.
        echo.>>"..\REPORT.lua"
    )
    
    rem ****************  Get list of MBINs in ModScript  ****************
    if %_bNumberMBINs% GTR 0 (
        CALL LIST_ModScriptMBINs.BAT
        echo.
        echo.>>"..\REPORT.lua"
    )
    
    REM if !_bCheckMODSconflicts! EQU 3 (
        REM set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
        REM if not defined _bStartTime (
            REM Call :LuaEndedOkREMOVE
            REM set location=bz11_StartTime.lua
            REM SET _bStartTime=Y
            REM %_mLUA% StartTime.lua "..\\" ""
            REM Call :LuaEndedOk
        REM )
        
        REM goto :START_CONFLICT_DETECTION
    REM ) else (
    
        REM set "_fileToCheck=MODS_pak_list.txt"
        REM CALL :HOW_MANY_LINES
    REM )
    
    echo.
    
    rem ******   NOW IN AMUMSS folder   ********
    cd ..

    if defined _pause (
        echo Q: AMUMSS: current directory: !CD!
        pause
    )
    
    if %_bNumberScripts% EQU 0 (
        echo. %_zBLACKonYELLOW%                                                                             %_zDEFAULT%
        echo. %_zBLACKonYELLOW% [NOTE] Placing one or more paks/mbins in Modscript, without a .lua script,  %_zDEFAULT%
        echo. %_zBLACKonYELLOW%              will unpack and decompile them...                              %_zDEFAULT%
        echo. %_zBLACKonYELLOW%     When possible, the current MBINCompiler will be used                    %_zDEFAULT%
        echo. %_zBLACKonYELLOW%                                                                             %_zDEFAULT%
        echo.
        if %_bNumberPAKs% GTR 1 (
            echo.^>^>^>   [INFO] AMUMSS is going to unpack and decompile them now...
        ) else (
            if %_bNumberPAKs% GTR 0 (
                echo.^>^>^>   [INFO] AMUMSS is going to unpack and decompile it now...
            )
        )
        if %_bNumberMBINs% GTR 1 (
            echo.^>^>^>   [INFO] AMUMSS is going to decompile them now...
        ) else (
            if %_bNumberMBINs% GTR 0 (
                echo.^>^>^>   [INFO] AMUMSS is going to decompile it now...
            )
        )
        echo.
        
        echo|set /p="[NOTE] Placing one or more paks/mbins in Modscript, without a .lua script will unpack and decompile them">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE] When possible, the current MBINCompiler will be used...">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
    ) else (
        echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
        echo. %_zBLACKonYELLOW% [NOTE] One or more paks with at least one .lua script to apply over them             %_zDEFAULT%
        echo. %_zBLACKonYELLOW%             will create a PATCH pak ^(the COMBINED pak^)                               %_zDEFAULT%
        echo. %_zBLACKonYELLOW%        And if the same mbin file is present in any of the .pak and edited by the     %_zDEFAULT%
        echo. %_zBLACKonYELLOW%        .lua script, only the one in the last pak will contribute to the COMBINED pak %_zDEFAULT%
        echo. %_zBLACKonYELLOW%        As always, the natural NMS load order will dictate its effects...             %_zDEFAULT%
        echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
        echo. %_zBLACKonYELLOW%        FOR THIS TO WORK, the pak^(s^) MUST be fully updated to the current NMS files   %_zDEFAULT%
        echo. %_zBLACKonYELLOW%        since the MBIN files in the pak are used to create the patch                  %_zDEFAULT%
        echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
        echo.
        REM echo. %_zBLACKonYELLOW%                                                                                   %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW% [NOTE] Remember that a PATCH must be used WITH the original .pak ^(in most cases^)  %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW%             to get the full effect of the original + your script                  %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW%                                                                                   %_zDEFAULT%
        REM echo.
        REM echo. %_zBLACKonYELLOW%                                                                                   %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW% [NOTE] RENAMING the PATCH is most probably required                               %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW%                                                                                   %_zDEFAULT%
        REM echo.
        
        echo.>>"REPORT.lua"
        echo|set /p="[NOTE] One or more paks with at least one .lua script to apply over them">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE]   will create a PATCH pak (the COMBINED pak) ">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE] When the same mbin file is present in any of the .pak and edited by the">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE]   .lua script, only the one in the last pak will contribute to the COMBINED pak">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE] As always, the natural NMS load order will dictate its effects...">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
        echo|set /p="[NOTE] FOR THIS TO WORK, the pak(s) MUST be fully updated to the current NMS files">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE]   since the MBIN files in the pak are used to create the patch">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
        REM echo|set /p="[NOTE] Remember that a PATCH must be used with the original .pak (in most cases)">>"REPORT.lua" & echo.>>"REPORT.lua"
        REM echo|set /p="[NOTE]   to get the full effect of the original + your script">>"REPORT.lua" & echo.>>"REPORT.lua"
        REM echo.>>"REPORT.lua"
        REM echo|set /p="[NOTE] RENAMING the PATCH is most probably required">>"REPORT.lua" & echo.>>"REPORT.lua"
        REM echo.>>"REPORT.lua"
    )
    
    if %_bNumberScripts% GTR 0 (
		if %_bNumberPAKs% GTR 0 (
			echo.^>^>^>      A PatchMod COMBINED MOD pak will be created...
			echo.^>^>^>      If you choose to COPY to your game folder, the PAKs will ALSO be copied there...
			SET "_bPATCH=1"
        ) else (
			rem only MBINs are present in ModScript
			echo.^>^>^>      A GENERIC COMBINED MOD pak will be created...
		)
		
        SET "_bCOMBINE_MOD_TYPE=1"
        REM SET _bCOPYtoNMS=NONE
        
        REM       with /r we look into sub-folders also: NOT WHAT WE WANT
        REM FOR /r "%~dp0\ModScript" %%G in (*.pak.*) do (
		
        rem used in case CreateMod.bat is used
		FOR %%G in ("%CD%\ModScript\*.pak.*") do (
            SET "_bPAKname=%%~nG"
            echo|set /p="- a patchMod to be used with %%~nG.pak">>"MODBUILDER\COMBINED_CONTENT_LIST.txt"
            echo.>>"MODBUILDER\COMBINED_CONTENT_LIST.txt"
        )
        goto :SIMPLE_MODE
    )
    set "location=bz35"
    REM echo. %time% %location%
)

rem --------------  end Check # of PAKs present ------------------------------
rem *************************   check if pak in ModScript, no script   ************************
rem *************************  UNPACK and DECOMPILE paks to TOOLS\UNPACKED_DECOMPILED_PAKs  ******************
if %_bNumberScripts% EQU 0 (
    set "location=bz36"
    REM echo. %time% %location%
    if DEFINED _bPAK_MBIN (
        rem one or more paks or mbins, no script. Extracting ALL files
        
        REM rem ------  START of automatic processing: start the clock  -----------------------
        
		if [!_DEV_MODE!]==[F] (
			echo.^>^>^> It is highly recommended to use DEVELOPMENT mode to shorten the time to unpack/decompile the PAKs
			CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Switch to DEV mod %_zDEFAULT%"
			if !ERRORLEVEL! EQU 1 set "_DEV_MODE=D"
		)
		
        if not [!_DEV_MODE!]==[F] (
            set "_bCheckVersionOfFiles=N"
        ) else (
            CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Check the version of each file prior to decompiling them %_zDEFAULT%"
            if !ERRORLEVEL! EQU 2 set "_bCheckVersionOfFiles=N"
            if !ERRORLEVEL! EQU 1 set "_bCheckVersionOfFiles=Y"
        )
        
        REM if %_bNumberPAKs% GTR 1 (
            if not defined _bStartTime (
                Call :LuaEndedOkREMOVE
                set "location=bz10_StartTime.lua"
                SET "_bStartTime=Y"
                MODBUILDER\%_mLUA% "MODBUILDER\StartTime.lua" ".\\" ".\\MODBUILDER\\"
                Call :LuaEndedOk
            )
        REM )
        
        if not exist ".\TOOLS\UNPACKED_DECOMPILED_PAKs" (
            mkdir ".\TOOLS\UNPACKED_DECOMPILED_PAKs\" 2>NUL
        )
        
        REM ***** in AMUMSS *****
		REM echo.^>^>^> We are in !CD!

        REM       with /r we look into sub-folders also
        REM FOR /r "%~dp0\ModScript" %%G in (*.pak.*) do (
        FOR %%G in ("%CD%\ModScript\*.pak.*") do (
            echo.
			set "process="
			set "name=%%G"
			REM echo.  name = !name!
			set "_dummy=!name:.pak.=!"
			REM echo. dummy = !_dummy!
			if not [!_dummy!]==[!name!] (
				REM echo. a .pak. extension
				set "process=Y"
			) else (
				rem echo. NOT a .pak. extension
				set "ext=%%~xG"
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
				SET "_bPAKname=%%~nG"
				rem set "_bPAKname=!_bPAKname:.=_!"
				echo. %_zBLACKonYELLOW% **** Unpacking/decompiling !_bPAKname! **** %_zDEFAULT%
				echo|set /p="%_INFO% **** Unpacking/decompiling !_bPAKname! ****">>"REPORT.lua" & echo.>>"REPORT.lua"
				
				rem clean any previous version of this pak
				echo.^>^>^> Cleaning folder %_zBRIGHTGREEN%TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!, %_zDEFAULT%please wait...
				rd /q /s ".\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" 1>NUL 2>NUL
				mkdir ".\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" 1>NUL 2>NUL
				
				rem echo.%_zBRIGHTGREEN%^>^>^> Copying original pak to TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname! folder, %_zDEFAULT%please wait...
				echo.^>^>^> Copying original pak to folder %_zBRIGHTGREEN%TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!%_zDEFAULT%
				xcopy /y /h "%%G" ".\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\*" 1>NUL 2>NUL
				
				mkdir ".\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK" 2>NUL
				mkdir ".\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" 2>NUL
				
				cd ModScript
				REM ******   NOW IN ModScript   ********

				if defined _pause (
					echo Q1: ModScript: current directory: !CD!
					pause
				)

				REM pushd !CD!
				REM cd ".\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK"
	REM echo.^>^>^> Changed to !CD!
				
				REM if exist EXTRACTED_PAK CALL :Cleaning_EXTRACTED_PAK
				REM if exist EXMLFILES_PAK CALL :Cleaning_EXMLFILES_PAK
				
				set "_bPaknamePATH=%%G"
				CALL ..\MODBUILDER\ExtractMODfromPAK.bat
				rem the PAKs are now unpacked to TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK
				rem OBSOLETE: and the last PAK is also unpacked to ModScript\EXTRACTED_PAK
				
				REM popd

				REM cd ..
				REM echo.^>^>^> Back in !CD!
				REM REM ***** in ModScript *****

				rem switch ON some actions
				set "_bDoingPAk=Y"

	REM echo. BEFORE UNPACKEDtoEXML
	REM pause
				set "_bCurrentPath=%_bMASTER_FOLDER_PATH%TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK\"
				call :UNPACKEDtoEXML
				rem the MBINs are now decompiled to TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK, if it was possible
				rem OBSOLETE: and the last PAK is also decompiled to ModScript\EXMLFILES_PAK
				set "_bUNPACKED_DECOMPILED=y"
				
				REM rem make sure those folders are not used by AMUMSS
				REM ECHO. >.\EXTRACTED_PAK\%_bDoNotUseName%
				REM ECHO. >.\EXMLFILES_PAK\%_bDoNotUseName%
				
				REM CALL :GET_CURRENT_EXML_for_COMPARISON
				
				cd ..
				rem ******   NOW IN AMUMSS folder   ********
				set "amumssFolder=!CD!"
				
				if defined _pause (
					echo Q2: AMUMSS: current directory: !CD!
					pause
				)
				
				pushd "TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!"
				if %_bNumberPAKs% EQU 1 (
					if [!_uOldMBINCompilerFlag!]==[N] (
						echo.
						FOR /r %%H in (*.lua) do (
							echo.   ^>^>^> Found this script in the PAK: [%%~nxH]
							
							if [%-UseLuaScriptInPak%]==[ASK] SET "_bUseLuaInPak="
							if [%-UseLuaScriptInPak%]==[] SET "_bUseLuaInPak="
							if [%-UseLuaScriptInPak%]==[Y] SET "_bUseLuaInPak=Y"
							if [%-UseLuaScriptInPak%]==[N] SET "_bUseLuaInPak=N"
							
							if not defined _UseLuaInPak (
								CHOICE /c:YN /m ".      %_zBLACKonYELLOW% ??? Do you want to rebuild the MOD pak(s) using this script %_zDEFAULT%"
								if !ERRORLEVEL! EQU 2 SET "_bUseLuaInPak=N" & echo.
								if !ERRORLEVEL! EQU 1 SET "_bUseLuaInPak=Y"
							)
							
							if [!_bUseLuaInPak!]==[Y] (
								echo.   Copying script to ModScript...
								set "_bNoScript="
								SET "_bBuildMODpak=y"
								SET "_bBuildMODpakFromPakScript=y"
								
								REM we use the scripts as normal scripts
								xcopy /y /h "EXTRACTED_PAK\%%~nxH" "!amumssFolder!\Modscript\*" 1>NUL 2>NUL
								
								REM copy all extra files found in that pak
								REM allow all file types, except .lua scripts and .MBIN
								rem echo|set /p=".MBIN>MODBUILDER\xcopy_exclude.txt"
                                xcopy /f /s /y /h /e /i /j /c "EXTRACTED_PAK\*.*" "!amumssFolder!\MODBUILDER\MOD\*" /EXCLUDE:MODBUILDER\xcopy_excludeBZRUN.txt 1>NUL 2>NUL
							)
						)
					)
				)
				rem copy all .lua to root folder
				xcopy /y ".\EXTRACTED_PAK\*.lua" "*" 1>NUL 2>NUL
				popd
			)
        )
        
        if %_bNumberMBINs% GTR 0 (
            cd ModScript

            if defined _pause (
                echo R: ModScript: current directory: !CD!
                pause
            )
            rem ******   NOW IN ModScript   ********
            if not exist EXTRACTED_PAK (
                mkdir EXTRACTED_PAK 2>NUL
            ) else (
                CALL :Cleaning_EXTRACTED_PAK
                mkdir EXTRACTED_PAK 2>NUL
            )
            
            ECHO. >.\EXTRACTED_PAK\%_bDoNotUseName%
            
            if not exist EXMLFILES_PAK (
                mkdir EXMLFILES_PAK 2>NUL
            ) else (
                CALL :Cleaning_EXMLFILES_PAK
                mkdir EXMLFILES_PAK 2>NUL
            )
            
            ECHO. >.\EXMLFILES_PAK\%_bDoNotUseName%
            
            set "_bCurrentPath=%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_PAK\"
            copy /y "*.MBIN" "EXTRACTED_PAK\" >NUL
            
            rem switch OFF some actions
            set "_bDoingPAk="
            
            call :UNPACKEDtoEXML
            set "_bUNPACKED_DECOMPILED=y"
            
            cd ..

            if defined _pause (
                echo S: AMUMSS: current directory: !CD!
                pause
            )
            rem ******   NOW IN AMUMSS folder   ********
        )
    )
    set "location=bz37"
    REM echo. %time% %location%
)
rem *************************  end UNPACK and DECOMPILE paks to TOOLS\UNPACKED_DECOMPILED_PAKs  ******************

rem ******   NOW IN AMUMSS folder   ********
rem re-calculate the number of scripts in ModScript
rem number of scripts could have changed:
Call :LuaEndedOkREMOVE
if [%_bUseLuaInPak%]==[Y] (
    cd MODBUILDER

    if defined _pause (
        echo T: MODBUILDER: current directory: !CD!
        pause
    )
    
    rem re-check # of script
    set "location=bz9_SearchModScriptForFileExt.lua"
    REM echo. %time% %location%
    rem Check if some LUA scripts exist in ModScript and sub-folders
    rem !_mLUA! SearchModScriptForFileExt.lua ".lua" "" "CreateCompositeName"
    !_mLUA! SearchModScriptForFileExt.lua ".lua"
    SET "_bResult=!ERRORLEVEL!"
    SET /A "_bNumberScripts=_bResult"
    Call :LuaEndedOk
    REM echo.
    REM echo. YYY_=_YYY _bNumberScripts = [%_bNumberScripts%]
    cd ..

    if defined _pause (
        echo U: AMUMSS: current directory: !CD!
        pause
    )
    set "location=bz36"
    REM echo. %time% %location%
)

            REM FOR %%G in ("%~dp0\ModScript\*.lua") do (
            REM FOR %%G in ("%CD%\ModScript\*.lua") do (
                REM SET /A _bNumberScripts=_bNumberScripts+1
            REM )
            
if %_bNumberScripts% EQU 0 (
    if DEFINED _bMXML (
        SET /A "_bNumberScripts=_bNumberScripts+1"
    )
)

if %_bNumberScripts% EQU 0 (
    set "_bNoScript=y"
) else (
    SET "_bBuildMODpak=y"
    CALL :CHECK_ExtraFilesToInclude
)

REM CALL :Cleaning_MXML_Helper

if [%_uOldMBINCompilerFlag%]==[Y] (
    echo.    %_zBLACKonYELLOW% [NOTICE] Older MBINCompiler used %_zDEFAULT%
    REM echo.
    
    echo.>>"REPORT.lua"
    echo|set /p=".   [NOTICE] Older MBINCompiler used">>"REPORT.lua" & echo.>>"REPORT.lua"
    
    REM script, if any, may need updating.  Not processing
    goto :ENDING
)

rem -------- user options start here -----------
rem on 0, treat as INDIVIDUAL mods
rem on 1, treat as a generic combined mod with a NUMERIC suffix
rem on 2, treat as a DISTINCT combined mod with the current DATE-TIME
rem on 3, treat as an INDIVIDUAL mod, the name being like Mod1+Mod2+Mod3.pak, a COMPOSITE mod

CALL :DOPAUSE

if defined _bNoScript goto :EXECUTE

REM set "-CombinedModType=0"

if %_bNumberScripts% EQU 1 (
    rem INDIVIDUAL mod
    SET "_bCOMBINE_MOD_TYPE=0"
    
    rem to bypass ASKing
    set "-CombineModPak=N"
    REM set "-CombinedModType=3"
)

if defined _mDEBUG (
    echo. ========================================
    echo. ====== before choices ===================
    echo.   -CombineModPak = [%-CombineModPak%]
    REM echo. -CombinedModType = [%-CombinedModType%]
    echo. ========================================
)

if [%-CombineModPak%]==[ASK] goto :AskCombineModPak
if [%-CombineModPak%]==[] goto :AskCombineModPak
rem if [%-CombineModPak%]==[Y] goto :WhatTypeOfCombinedMod
if [%-CombineModPak%]==[Y] goto :SIMPLE_MODE
if [%-CombineModPak%]==[N] goto :INDIVIDUAL_SELECTED

echo.==^> BAD OPTION VALUE for '-CombineModPak' [%-CombineModPak%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause

:AskCombineModPak
echo.
echo. %_zWHITEonDARKCYAN%                                                                                                                                       %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%  - INDIVIDUAL PAKs may or may not work together depending on the EXML files they change                                               %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%      If they modify the same original EXML files, the last one loaded will win and the other changes will be lost...                  %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%      Use INDIVIDUAL PAKs when they don't 'conflict' with each other                                                                   %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%                                                                                                                                       %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%  - COMBINED PAKs will try to keep, as much as possible, all changes made to a particular EXML file by re-using it during PAK creation %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%      Only the last change made to the same exact values of an EXML will be in the mod                                                 %_zDEFAULT%
echo. %_zWHITEonDARKCYAN%                                                                                                                                       %_zDEFAULT%

REM if [%-CombineModPak%]==[N] goto :WhatTypeOfCombinedMod
REM if [%-CombineModPak%]==[Y] goto :WhatTypeOfCombinedMod

CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to create a COMBINED[Y] or INDIVIDUAL[N] mods %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 set "-CombineModPak=N"
if %ERRORLEVEL% EQU 1 set "-CombineModPak=Y"

if [%-CombineModPak%]==[N] goto :INDIVIDUAL_SELECTED

rem =============== COMBINED ==============
REM :WhatTypeOfCombinedMod
REM if [%-CombinedModType%]==[0] goto :AskCombinedModType
REM if [%-CombinedModType%]==[ASK] goto :AskCombinedModType
REM if [%-CombinedModType%]==[] goto :AskCombinedModType

REM if [%-CombinedModType%]==[1] (
    REM rem SET "_bCOMBINE_MOD_TYPE=1"
    REM SET "_bCOMBINE_MOD_TYPE=3"
    REM goto :SIMPLE_MODE
REM )
REM if [%-CombinedModType%]==[2] (
    REM SET "_bCOMBINE_MOD_TYPE=2"
    REM goto :SIMPLE_MODE
REM )
REM if [%-CombinedModType%]==[3] (
    REM SET "_bCOMBINE_MOD_TYPE=3"
    REM goto :SIMPLE_MODE
REM )

REM echo.==^> BAD OPTION VALUE for '-CombinedModType' [%-CombinedModType%], please correct!
REM echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
REM pause

REM :AskCombinedModType
REM echo.
REM echo. %_zWHITEonDARKCYAN%                                                                                    %_zDEFAULT%
REM echo. %_zWHITEonDARKCYAN%     ^>^>^> Available pak Types:                                                       %_zDEFAULT%
REM REM echo. %_zWHITEonDARKCYAN%          1 - CombinedMod_DATE_TIME.pak                                  %_zDEFAULT%
REM echo. %_zWHITEonDARKCYAN%          2 - CombinedMod_(x).pak ^(x = index number of last combined script in pak^) %_zDEFAULT%
REM echo. %_zWHITEonDARKCYAN%          3 - mod1+mod2+mod3.pak ^(a composite name of the combined mods^)            %_zDEFAULT%
REM echo. %_zWHITEonDARKCYAN%                                                                                    %_zDEFAULT%

REM rem CHOICE /c:123 /m " %_zBLACKonYELLOW% ??? Your choice: %_zDEFAULT%"
REM CHOICE /c:23 /m " %_zBLACKonYELLOW% ??? Your choice: %_zDEFAULT%"
REM REM if %ERRORLEVEL% EQU 3 SET "_bCOMBINE_MOD_TYPE=3"
REM REM if %ERRORLEVEL% EQU 2 SET "_bCOMBINE_MOD_TYPE=2"
REM REM if %ERRORLEVEL% EQU 1 SET "_bCOMBINE_MOD_TYPE=1"
REM if %ERRORLEVEL% EQU 2 SET "_bCOMBINE_MOD_TYPE=3"
REM if %ERRORLEVEL% EQU 1 SET "_bCOMBINE_MOD_TYPE=2"

REM REM echo.
REM REM echo.^>^>^> A COMPOSITE combined MOD name has a length limit of less than %_bMaxPakNameLength% characters (excess will be truncated)
REM REM REM set /p _bCompositeName=<"MODBUILDER\Composite_MOD_FILENAME.txt"
REM REM echo.            It would be like mod1+mod2+mod3.pak
REM REM REM echo.      "%_bCompositeName%"
REM REM REM echo.               ...in this case
REM REM echo.
REM REM CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to use a COMPOSITE combined MOD named just like that %_zDEFAULT%"
REM REM if %ERRORLEVEL% EQU 2 goto :COMBINEDTYPE
REM REM if %ERRORLEVEL% EQU 1 SET "_bCOMBINE_MOD_TYPE=3"
REM REM goto :SIMPLE_MODE

REM REM :COMBINEDTYPE
REM REM echo.
REM REM echo.^>^>^> A COMBINED MOD name can be like CombinedMod_(x).pak (where x is 0 to 9)
REM REM echo.                         ...or like CombinedMod_DATE-TIME.pak...
REM REM echo.
REM REM CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to use a NUMERIC suffix[Y] or the current DATE-TIME[N] to differentiate your mod name %_zDEFAULT%"
REM REM if %ERRORLEVEL% EQU 2 SET "_bCOMBINE_MOD_TYPE=1"
REM REM if %ERRORLEVEL% EQU 1 SET "_bCOMBINE_MOD_TYPE=2"
REM REM goto :SIMPLE_MODE

rem [%-CombineModPak%]==[Y] was choosen
SET "_bCOMBINE_MOD_TYPE=3"

REM rem here _bCOMBINE_MOD_TYPE is set
REM rem =============== END: COMBINED ==============

rem =============== INDIVIDUAL ==============
:INDIVIDUAL_SELECTED
REM if [%-IndividualModPakType%]==[ASK] goto :ASKIndividualModPakType
REM if [%-IndividualModPakType%]==[] goto :ASKIndividualModPakType
REM if [%-IndividualModPakType%]==[PLAIN] (
    REM SET "_bINDIVIDUAL_MODS=2"
    REM goto :SIMPLE_MODE
REM )
REM if [%-IndividualModPakType%]==[P] (
    REM SET "_bINDIVIDUAL_MODS=2"
    REM goto :SIMPLE_MODE
REM )
REM if [%-IndividualModPakType%]==[DATETIME] (
    REM SET "_bINDIVIDUAL_MODS=1"
    REM goto :SIMPLE_MODE
REM )
REM if [%-IndividualModPakType%]==[D] (
    REM SET "_bINDIVIDUAL_MODS=1"
    REM goto :SIMPLE_MODE
REM )

REM echo.==^> BAD OPTION VALUE for '-IndividualModPakType' [%-IndividualModPakType%], please correct!
REM echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
REM pause

REM :ASKIndividualModPakType
REM rem _bINDIVIDUAL_MODS=1 the name of the script
REM rem _bINDIVIDUAL_MODS=2 the name of the script + date-time
REM echo.
REM echo.^>^>^> Making individual MODs named like MyMod.pak
REM echo.                           ...or like MyMod_DATE-TIME.pak...
REM echo.
REM CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to add the current DATE-TIME[Y] to your mod name %_zDEFAULT%"
REM if %ERRORLEVEL% EQU 2 SET "_bINDIVIDUAL_MODS=2"
REM if %ERRORLEVEL% EQU 1 SET "_bINDIVIDUAL_MODS=1"
REM rem =============== END: INDIVIDUAL ==============

:SIMPLE_MODE

if %_bNumberScripts% EQU 1 goto :SIMPLE_MODE_ONE_SCRIPT
REM echo. XXX_=_XXX _bNumberScripts = [%_bNumberScripts%]

REM echo. 0_BXRUN: -CopyToGamefolder = [%-CopyToGamefolder%]
if [%-CopyToGamefolder%]==[ASK] goto :COPYASK
if [%-CopyToGamefolder%]==[] goto :COPYASK
SET "_bCOPYtoNMS=NONE"
if [%-CopyToGamefolder%]==[NONE] goto :EXECUTE
if [%-CopyToGamefolder%]==[N] goto :EXECUTE
SET "_bCOPYtoNMS=SOME"
if [%-CopyToGamefolder%]==[SOME] goto :EXECUTE
SET "_bCOPYtoNMS=ALL"
if [%-CopyToGamefolder%]==[ALL] goto :EXECUTE
if [%-CopyToGamefolder%]==[Y] goto :EXECUTE

echo.==^> BAD OPTION VALUE for '-CopyToGamefolder' [%-CopyToGamefolder%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause

:COPYASK
echo.
CHOICE /c:NSA /m " %_zBLACKonYELLOW% ??? Would you like or [N]ot to COPY [S]ome or [A]ll Created Mods to your game folder %_zDEFAULT%"
if %ERRORLEVEL% EQU 3 SET "_bCOPYtoNMS=ALL"
if %ERRORLEVEL% EQU 2 SET "_bCOPYtoNMS=SOME"
if %ERRORLEVEL% EQU 1 SET "_bCOPYtoNMS=NONE"

goto :EXECUTE

:SIMPLE_MODE_ONE_SCRIPT
if [%-CopyToGamefolder%]==[ASK] goto :ASK_COPYTOMODS
if [%-CopyToGamefolder%]==[] goto :ASK_COPYTOMODS

SET "_bCOPYtoNMS=NONE"
if [%-CopyToGamefolder%]==[NONE] goto :EXECUTE
if [%-CopyToGamefolder%]==[N] goto :EXECUTE

SET "_bCOPYtoNMS=ALL"
if [%-CopyToGamefolder%]==[SOME] goto :EXECUTE
if [%-CopyToGamefolder%]==[ALL] goto :EXECUTE
if [%-CopyToGamefolder%]==[Y] goto :EXECUTE

echo.==^> BAD OPTION VALUE for '-CopyToGamefolder' [%-CopyToGamefolder%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause
goto :COPYASK

:ASK_COPYTOMODS
if %_bNumberScripts% EQU 0 (
    REM echo. _bNumberScripts is 0
    set "_bCOPYtoNMS=NONE"
    goto :EXECUTE
)

echo.
CHOICE /c:YN /m " %_zBLACKonYELLOW% ??? Would you like to COPY created Mods to your game folder %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 SET "_bCOPYtoNMS=NONE"
if %ERRORLEVEL% EQU 1 SET "_bCOPYtoNMS=ALL"
rem -------- user options end here -----------

:EXECUTE

if defined _mDEBUG (
    echo. ========================================
    echo. ====== after choices ===================
    echo.     -CombineModPak = [%-CombineModPak%]
    REM echo.   -CombinedModType = [%-CombinedModType%]
    echo. _bCOMBINE_MOD_TYPE = [%_bCOMBINE_MOD_TYPE%]
    echo. ========================================
)

Del /f /q ".\ModBackups\*.*" 1>NUL 2>NUL

REM Del /f /q /s ".\CreatedMODS\*.*" 1>NUL 2>NUL
CALL :Cleaning_CREATEDMODS
CALL :Cleaning_TOOLS\MODDER_Helper

Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOk.txt" 1>NUL 2>NUL
Del /f /q "LuaEndedOk.txt" 1>NUL 2>NUL

Del /f /q "TempScript.lua" 1>NUL 2>NUL
Del /f /q "TempScriptORG.lua" 1>NUL 2>NUL
Del /f /q "TempTable.lua" 1>NUL 2>NUL

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

if defined _pause (
    echo U1: MODBUILDER: current directory: !CD!
    pause
)
del /f /q OnlyOneScript.txt 1>NUL 2>NUL

if %_bNumberScripts% EQU 1 (
    echo|set /p="">OnlyOneScript.txt
)

REM echo. EEE_=_EEE_0 _bPAK_MBIN = [%_bPAK_MBIN%]

if not DEFINED _bPAK_MBIN (
REM echo. EEE_=_EEE_0 _bPAK_MBIN = [%_bPAK_MBIN%]
    CALL :CONFLICTDETECTION
REM echo _bCheckMODSconflicts = !_bCheckMODSconflicts!

    if !_bCheckMODSconflicts! EQU 1 (
        REM get list of paks in NMS MODS folder > MODS_pak_list.txt
        CALL PSARC_LIST_PAKS_MODS.BAT
    )
    if !_bCheckMODSconflicts! EQU 3 (
        REM get list of paks in NMS MODS folder > MODS_pak_list.txt
        CALL PSARC_LIST_PAKS_MODS.BAT
    )
    
    REM if !_bCheckMODSconflicts! EQU 3 (
        REM set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
        REM if not defined _bStartTime (
            REM Call :LuaEndedOkREMOVE
            REM set location=bz8_StartTime.lua
            REM SET _bStartTime=Y
            REM %_mLUA% StartTime.lua "..\\" ""
            REM Call :LuaEndedOk
        REM )
        
        REM goto :START_CONFLICT_DETECTION
    REM ) else (
    
        REM set "_fileToCheck=MODS_pak_list.txt"
        REM CALL :HOW_MANY_LINES
        
    REM )
    
    REM CALL :PAK_LISTsCREATION
)

REM rem **************************  MapFileTrees creation choice section  ********************************
if [%-ReCreateMapFileTree%]==[ASK] goto :AskReCreateMapFileTree
if [%-ReCreateMapFileTree%]==[] goto :AskReCreateMapFileTree
if [%-ReCreateMapFileTree%]==[Y] goto :CleanMapFileTreeFolder
if [%-ReCreateMapFileTree%]==[N] goto :START
if [%-ReCreateMapFileTree%]==[X] goto :START

echo.==^> BAD OPTION VALUE for '-ReCreateMapFileTree' [%-ReCreateMapFileTree%], please correct!
echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
pause

:AskReCreateMapFileTree
echo.
if defined _bNMSUpdated (
    echo.^>^>^> There was a NMS update, it is recommended to recreate the MapFileTrees files
    echo.
    echo.^>^>^> Some of your MapFileTrees files may be outdated
    echo.^>^>^>    You can recreate them using the script MapFileTree_UPDATER.lua
    echo.^>^>^>    To update a specific file, add it to the script
    echo.^>^>^> All other MapFileTrees will be updated as you process other scripts
)

echo.
CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to FORCE (RE)CREATE the MapFileTrees files DURING script processing %_zDEFAULT%"
if %ERRORLEVEL% EQU 0 (set "-ReCreateMapFileTree=Y")
rem **************************  end MapFileTrees creation choice section  ********************************

if not [%-ReCreateMapFileTree%]==[Y] goto :START

:CleanMapFileTreeFolder
Call :Cleaning_MapFileTrees

:START
REM echo. AAA_=_AAA _bNoScript = [%_bNoScript%]
rem ------  START of automatic processing: start the clock  -----------------------
if not defined _bStartTime (
    Call :LuaEndedOkREMOVE
    set "location=bz7_StartTime.lua"
    SET "_bStartTime=Y"
    %_mLUA% StartTime.lua "..\\" ""
    Call :LuaEndedOk
)
REM echo. BBB_=_BBB _bNoScript = [%_bNoScript%]
REM echo. BBB_=_BBB _bNumberPAKs = [%_bNumberPAKs%]
REM echo. BBB_=_BBB _bNumberScripts = [%_bNumberScripts%]
if %_bNumberPAKs% GTR 0 (
    echo.
    if %_bNumberScripts% GTR 0 (
        echo.---------------------------------------------------------
        echo.^>^>^> So, we are making a PatchMod COMBINED MOD PAK...
        echo|set /p="%_INFO%   A PatchMod COMBINED MOD will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        if defined _bExtraFilesInPAK (
            echo.^>^>^>      Extra Files in ModScript\GlobalMEFTI will be included
            echo|set /p="%_INFO%   Extra Files in ModScript\GlobalMEFTI will be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        ) else (
            if !_bExtraFiles! GTR 0 (
                echo.^>^>^>      Extra Files in ModScript\GlobalMEFTI will NOT be included
                echo|set /p="%_INFO%   Extra Files in ModScript\GlobalMEFTI will NOT be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            )
        )
        if [%_bCOPYtoNMS%]==[NONE] (
            echo.^>^>^>      It will NOT be copied to NMS MOD folder
            echo|set /p="%_INFO%   It will NOT be copied to NMS MOD folder">>"..\REPORT.lua"
        )
        if [%_bCOPYtoNMS%]==[ALL] (
            if %_bNumberPAKs% GTR 1 (
                echo.^>^>^>      and will be copied with the user PAKs to NMS MOD folder
                echo|set /p="%_INFO%   and will be copied with the user PAKs to NMS MOD folder">>"..\REPORT.lua"
            ) else (
                echo.^>^>^>      and will be copied with the user PAK to NMS MOD folder
                echo|set /p="%_INFO%   and will be copied with the user PAK to NMS MOD folder">>"..\REPORT.lua"
            )
        )
    )
    echo.>>"..\REPORT.lua"
    echo.>>"..\REPORT.lua"
) else (
    if defined _bNoScript goto :SIMPLE_MODE2
    echo.
    echo.---------------------------------------------------------

    if %_bCOMBINE_MOD_TYPE% EQU 0 (
        if defined _bAMM_AUTOselect (
            echo.^>^>^> %_zBRIGHTGREEN%Auto-selected%_zDEFAULT% by AMM ^(AMUMSS ModScript Manager^)
            echo|set /p="%_INFO% >>> Auto-selected by AMM (AMUMSS ModScript Manager)">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        )

        echo.^>^>^> So, we are making INDIVIDUAL MODs ^(except where ___COMBINE.txt exist in sub-folders^)...
        echo|set /p="%_INFO% INDIVIDUAL MODs will be created (except where ___COMBINE.txt exist in sub-folders)...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    )
    if %_bCOMBINE_MOD_TYPE% EQU 1 (
        echo.^>^>^> So, we are making a GENERIC COMBINED MOD...
        echo|set /p="%_INFO% A GENERIC COMBINED MOD will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    )
    if %_bCOMBINE_MOD_TYPE% EQU 2 (
        echo.^>^>^> So, we are making one or more DISTINCT COMBINED MODs...
        echo|set /p="%_INFO% One or more DISTINCT COMBINED MODs will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    )
    if %_bCOMBINE_MOD_TYPE% EQU 3 (
        echo.^>^>^> So, we are making a COMPOSITE-NAME COMBINED MOD...
        echo.^>^>^>   unless "MOD_BATCHNAME" is specified in a script
        echo|set /p="%_INFO% A COMPOSITE-NAME COMBINED MOD will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        echo|set /p="%_INFO% unless 'MOD_BATCHNAME' is specified in a script">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    )
    if defined _bExtraFilesInPAK (
        echo.^>^>^>      Extra Files in ModScript\GlobalMEFTI will be included
        echo|set /p="%_INFO% Extra Files in ModScript\GlobalMEFTI will be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    ) else (
        if !_bExtraFiles! GTR 0 (
            echo.^>^>^>      Extra Files in ModScript\GlobalMEFTI will NOT be included
            echo|set /p="%_INFO% Extra Files in ModScript\GlobalMEFTI will NOT be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        )
    )
    
    if [%_bCOPYtoNMS%]==[NONE] (
        echo.^>^>^>      and NONE will be copied to NMS MODS folder
        echo|set /p="%_INFO%   and NONE will be copied to NMS MODS folder">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    )
    if [%_bCOPYtoNMS%]==[ALL] (
        echo.^>^>^>      and ALL will be copied to NMS MODS folder
        echo.^>^>^>      %_zBRIGHTORANGE%NOTE: YOU are RESPONSIBLE for deleting sub-folders from previous COMBINE runs in GAMEDATA^\MODS%_zDEFAULT%
        echo|set /p="%_INFO% and ALL will be copied to NMS MODS folder">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        echo|set /p="%_INFO% NOTE: YOU are RESPONSIBLE for deleting sub-folders from previous COMBINE runs in GAMEDATA\MODS">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    )
    echo.>>"..\REPORT.lua"
)
echo.---------------------------------------------------------

REM if defined _mSIMPLE goto :SIMPLE_MODE2
REM if defined _min_subprocess goto :SIMPLE_MODE2

REM if not defined _mSKIP_USER_PAUSE (
    REM REM echo.Waiting 3 sec...
    REM timeout /T 3 /NOBREAK
REM )

rem *********************  STILL IN MODBUILDER  *******************
:SIMPLE_MODE2
REM echo. CCC_=_CCC _bBuildMODpak = [%_bBuildMODpak%]
if not defined _bBuildMODpak goto :ENDING

Del /f /q "..\SerializedScript.lua" 1>NUL 2>NUL

rem Let MapFileTreeCreator know it can run if requested
echo|set /p="">MapFileTreeCreatorRun.txt

rem ###################################################################
rem --------  processing only if scripts are present -------------
rem ###################################################################
				rem reset counter of processed scripts
				echo|set /p="">ScriptCounter.txt
				
				set "location=bz6_START_LoadAndExecuteModScript.lua"
				REM echo. %time% %location%
				
				if defined _mDEV (
					echo. %gcWARNING% LOADING LoadAndExecuteModScript_DEV %_zDEFAULT%
				)
                
                del exitCode.txt 1>NUL 2>NUL
				Call :LuaEndedOkREMOVE
				if exist LoadAndExecuteModScript_DEV.lua (
					%_mLUA% LoadAndExecuteModScript_DEV.lua
				) else (
					%_mLUA% LoadAndExecuteModScript.lua
				)
                if exist "exitCode.txt" (
                    set /p exitCode=<"exitCode.txt"
                )
                REM echo exitCode = [!exitCode!]
				Call :LuaEndedOk
				
                if [!exitCode!]==[BADPAKTYPE] (
					goto :eof
				)
                if [!exitCode!]==[BADAMUMSSFOLDER] (
                    goto :eof
                )

				if [!exitCode!]==[1] (
					SET "_bCOMBINE_MOD_TYPE=3"
				)
				
				set "location=bz6_END_LoadAndExecuteModScript.lua"
				REM echo. %time% %location%
				
				rem get # of processed script
				SET /p _bScriptCounter=<ScriptCounter.txt
				
				IF EXIST "LoadScriptAndFilenamesERROR.txt" (
					set "_bErrorLoadingScript=y"
				)
				
				REM CALL :DOPAUSE
				IF DEFINED _bErrorLoadingScript (
					echo|set /p="    [ENDED THIS SCRIPT PROCESSING] =========================================================">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
					echo.
				)
				rem set "_bErrorLoadingScript="
				del /f /q LoadScriptAndFilenamesERROR.txt 1>NUL 2>NUL
				
rem ##########################################################################
rem --------  END: processing only if scripts are present -------------
rem ##########################################################################

rem Let MapFileTreeCreator know it can terminate if it has completed its works
Del /f /q MapFileTreeCreatorRun.txt 1>NUL 2>NUL

:ENDING
echo.
echo.^>^>^>  Ending phase...

rem ******   NOW IN AMUMSS folder   ********
cd "%~dp0"
cd ..

if defined _pause (
    echo V: AMUMSS: current directory: !CD!
    pause
)

REM echo. CCC_=_CCC _bNoScript = [%_bNoScript%]
REM echo. CCC_=_CCC _bNumberPAKs = [%_bNumberPAKs%]
REM echo. CCC_=_CCC _bNumberScripts = [%_bNumberScripts%]

REM rem if more than one script
REM if not [%_DEV_MODE%]==[L] (
	REM if %_bNumberScripts% GTR 1 (
		REM if %_bCOMBINE_MOD_TYPE% EQU 0 (
			REM rem more then one script and individual mods
			REM rem we switch to LEAN mode
			REM echo.
			REM echo.  ==^> %_zWHITEonDARKCYAN% Switching to LEAN mode: Found more than one script AND creating INDIVIDUAL mods %_zDEFAULT%
			REM echo|set /p="%_INFO% Switching to LEAN mode: Found more than one script AND creating INDIVIDUAL mods">>"REPORT.lua" & echo.>>"REPORT.lua"
			REM set "_DEV_MODE=L"
		REM )
	REM )
REM )

REM if %_bNumberScripts% GTR 0 (
    REM if [%_DEV_MODE%]==[L] (
		REM if not exist ".\TOOLS\MXML_Helper" (
			REM mkdir ".\TOOLS\MXML_Helper\" 2>NUL
		REM )
		REM echo|set /p="">".\TOOLS\MXML_Helper\____NOTICE____ LEAN_MODE_ACTIVE.txt"
        REM call :DEV_MODE_INFO
        REM echo.
        REM echo.^>^>^>  %_zWHITEonDARKCYAN% LEAN mode: Skipping TOOLS\MXML_Helper update %_zDEFAULT%
        REM echo.}>>"REPORT.lua"
        REM echo|set /p="%_INFO% In LEAN mode: Skipping TOOLS\MXML_Helper update">>"REPORT.lua" & echo.>>"REPORT.lua"
    REM ) else (
        REM REM ECHO. A: !TIME!
        REM del ".\TOOLS\MXML_Helper\____NOTICE____ LEAN_MODE_ACTIVE.txt" 1>NUL 2>NUL
        REM echo.
        REM echo.^>^>^>  Cleaning TOOLS\MXML_Helper...

        REM CALL :Cleaning_MXML_Helper
        
        REM if %_bNumberScripts% GTR 1 (
            REM echo.^>^>^> %_bB%     Note that the MODDED files ARE based on the last processed script ^(for an individual mod^) or scripts ^(for a combined mod^)
            REM echo|set /p="%_INFO%     --Note that the MODDED files ARE based on the last processed script (for an individual mod) or scripts (for a combined mod)">>"REPORT.lua" & echo.>>"REPORT.lua"
        REM )
        
        REM REM rem works BUT this bat still need to wait for it to complete to close
        REM REM REM set "_AMUMSS_PATH=%CD%"
        REM REM REM rem set "command=cmd /c !_AMUMSS_PATH!\MODBUILDER\UpdateHelper.bat"
        REM REM REM rem set "command=!_AMUMSS_PATH!\MODBUILDER\UpdateHelper.bat"
        REM REM set "command=MODBUILDER\UpdateHelper.bat"
        REM REM REM set "command=UpdateHelperCaller.bat"
        REM REM START "" /MIN "!command!"
        
        REM REM ECHO. B: !TIME!
        REM echo.^>^>^> %_bB% Updating %_zBRIGHTGREEN%TOOLS\MXML_Helper\MODDED...%_zDEFAULT%
        REM echo.}>>"REPORT.lua"
        REM echo|set /p="%_INFO% Updated TOOLS\MXML_Helper\MODDED">>"REPORT.lua" & echo.>>"REPORT.lua"
        
        REM REM allow all file types, except .MBIN.  No empty folders
        REM rem xcopy /f /s /y /h /i /j /c "MODBUILDER\MOD\*.*" "TOOLS\MXML_Helper\MODDED\" /EXCLUDE:MODBUILDER\xcopy_exclude.txt 1>NUL 2>NUL
        REM robocopy "MODBUILDER\MOD" "TOOLS\MXML_Helper\MODDED" "*.*" /S /MOVE /J /NP /R:0 /MT:8 /XF /MT:12 *.MBIN 1>NUL 2>NUL
        
        REM REM ECHO. C: !TIME!
        REM echo.^>^>^> %_bB% Updating %_zBRIGHTGREEN%TOOLS\MXML_Helper\ORG_MXML...%_zDEFAULT%
        REM echo|set /p="%_INFO% Updated TOOLS\MXML_Helper\ORG_MXML">>"REPORT.lua" & echo.>>"REPORT.lua"
        
        REM REM rem get all original .EXML files from DECOMPILED and keep them still in DECOMPILED
        REM REM echo.     ^>^>^> %_bB% *.EXML...
        REM REM for /R .\TOOLS\MXML_Helper\MODDED\ %%G in (*.EXML) do (
            REM REM REM echo. - %%G
            REM REM set "_org=%%G"
            REM REM rem echo. - !_org!
            REM REM rem echo.
            REM REM set "_tmpDest=!_org:MODDED=ORG_MXML!"
            REM REM REM echo. - _tmpDest = [!_tmpDest!]
            REM REM set "_tmpSrc=!_org:TOOLS\MXML_Helper\MODDED=MODBUILDER\_TEMP\DECOMPILED!"
            REM REM REM echo. - _tmpSrc = [!_tmpSrc!]
            REM REM REM allow all file types
            REM REM start /B "" xcopy /s /y /h /i /j /c "!_tmpSrc!" "!_tmpDest!*" 1>NUL 2>NUL
        REM REM )
        
        REM REM ECHO. %TIME%
        REM rem get all original file types not .EXML from EXTRACTED and keep them still in EXTRACTED
        REM REM echo.     ^>^>^> %_bB% Other files...
        REM for /R .\TOOLS\MXML_Helper\MODDED\ %%G in (*.*) do (
            REM REM set "_ext=%%~xG"
            REM REM REM echo. - !_ext!
            REM REM if NOT [!_ext!]==[.EXML] (

            REM REM echo. - %%G
            REM set "_org=%%G"
            REM rem echo. - !_org!
            
            REM rem echo.
            REM set "_tmpDest=!_org:MODDED=ORG_MXML!"
            REM REM echo. - _tmpDest = [!_tmpDest!]

            REM if NOT [%%~xG]==[.MXML] (
                REM set "_tmpSrc=!_org:TOOLS\MXML_Helper\MODDED=MODBUILDER\_TEMP\EXTRACTED!"
            REM ) else (
                REM set "_tmpSrc=!_org:TOOLS\MXML_Helper\MODDED=MODBUILDER\_TEMP\DECOMPILED!"
            REM )

            REM REM echo. - _tmpSrc = [!_tmpSrc!]
            REM if exist "!_tmpSrc!" (
                REM REM allow all file types
                REM rem xcopy /s /y /h /i /j /c "!_tmpSrc!" "!_tmpDest!*" 1>NUL 2>NUL
                REM start /B "" xcopy /s /y /h /i /j /c "!_tmpSrc!" "!_tmpDest!*" 1>NUL 2>NUL
            REM )
        REM )
    REM )
REM )
REM ECHO. D: %TIME%

echo.
echo.%_zDARKGRAY%-----------------------------------------------------%_zDEFAULT%
echo.   %_zBLACKonYELLOW% ^>^>^>        AMUMSS v%_mCurrentVersion% finished        ^<^<^< %_zDEFAULT%
echo.%_zDARKGRAY%-----------------------------------------------------%_zDEFAULT%
echo.

if defined _bNoScript (
    if %_bNumberPAKs% EQU 0 (
        echo. %_zBLACKonYELLOW% ^>^>^>   [NOTICE] NO user .lua Mod Script found in ModScript... %_zDEFAULT%
        echo.              You may want to put some .lua Mod script in the ModScript folder and retry...
        
        echo|set /p="}   [NOTICE] No user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="%_INFO% You may want to put some .lua Mod script in the ModScript folder and retry...">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
    ) else (
        if %_bNumberScripts% EQU 0 (
            echo. %_zBLACKonYELLOW% ^>^>^>   [INFO] NO user .lua Mod Script found in ModScript... %_zDEFAULT%
            
            echo|set /p="}   [INFO] NO user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
            echo.>>"REPORT.lua"
        )
    )
) else (
    if not defined _bErrorLoadingScript (
        if [%_DEV_MODE%]==[L] (
            echo.^>^>^> [INFO] Created MODs are in local folders ^>^>^> %_zBRIGHTGREEN%CreatedMODS / ModBackups%_zDEFAULT% ^<^<^<
            echo.^>^>^> [INFO] and Backups in ^>^>^> %_zBRIGHTGREEN%IncrementalBuilds%_zDEFAULT% ^<^<^<
        ) else (
            echo.^>^>^> [INFO] Created MODs are in local folders ^>^>^> %_zBRIGHTGREEN%CreatedMODS / ModBackups%_zDEFAULT% ^<^<^<
            echo.^>^>^> [INFO] and Backups in ^>^>^> %_zBRIGHTGREEN%BuildHistory%_zDEFAULT% ^<^<^< and ^>^>^> %_zBRIGHTGREEN%IncrementalBuilds%_zDEFAULT% ^<^<^<
        )
        
        echo.>>"REPORT.lua"
        if [%_DEV_MODE%]==[L] (
            echo|set /p="%_INFO% Created MODs are in local folders >>> CreatedMODS / ModBackups <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
            echo|set /p="%_INFO% and Backups in >>> IncrementalBuilds <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
        ) else (
            echo|set /p="%_INFO% Created MODs are in local folders >>> CreatedMODS / ModBackups <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
            echo|set /p="%_INFO% and Backups in >>> BuildHistory <<< and >>> IncrementalBuilds <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
        )
        echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
        echo|set /p="%_INFO% END OF PROCESSING">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="%_INFO% Total scripts processed: %_bScriptCounter%">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
    )
)
Call :LuaEndedOkREMOVE

:START_CONFLICT_DETECTION
rem ******   NOW IN AMUMSS folder   ********
cd "%~dp0"
cd ..

REM if defined _pause (
    REM echo W: AMUMSS: current directory: !CD!
    REM pause
REM )

REM if !_bCheckMODSconflicts! NEQ 2 (
    REM rem %_bCheckMODSconflicts% EQU 1 >>> Y (both MODS and Scripts) >>> at least MODBUILDER\MODS_pak_list.txt
    REM rem %_bCheckMODSconflicts% EQU 2 >>> None
    REM rem %_bCheckMODSconflicts% EQU 3 >>> MODS only >>> MODBUILDER\MODS_pak_list.txt
    REM rem %_bCheckMODSconflicts% EQU 4 >>> Scripts only >>> MODBUILDER\MBIN_PAKS.txt
    
    REM if !_bCheckMODSconflicts! EQU 1 set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
    REM if !_bCheckMODSconflicts! EQU 3 set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
    REM if !_bCheckMODSconflicts! EQU 4 set "_fileToCheck=MODBUILDER\MBIN_PAKS.txt"
    REM REM echo._fileToCheck = !_fileToCheck!
    
    REM CALL :HOW_MANY_LINES
    
    REM REM echo _bCheckMODSconflicts = !_bCheckMODSconflicts!
    REM if !_bCheckMODSconflicts! NEQ 2 (
        REM if !_bGConflictLines! GTR 0 (
            REM echo.
            REM echo.^>^>^> Conflict Detection starting...
            REM REM if !_bCheckMODSconflicts! EQU 3 (
                REM REM echo|set /p="%_INFO% Only checking conflicts in MODS, at user request">>"REPORT.lua" & echo.>>"REPORT.lua"
            REM REM )
            
            REM REM if !_bCheckMODSconflicts! EQU 4 (
                REM REM echo|set /p="%_INFO% Only checking conflicts in ModScript, at user request">>"REPORT.lua" & echo.>>"REPORT.lua"
            REM REM )
            
            REM rem *********************  NOW IN MODBUILDER  *******************
            REM cd MODBUILDER

            REM Call :LuaEndedOkREMOVE
            REM set "location=bz5_CheckCONFLICTLOG.lua"
            REM %_mLUA% "CheckCONFLICTLOG.lua" "..\\" "" "" !_bCheckMODSconflicts!
            REM Call :LuaEndedOk
            
            REM rem ******   NOW IN AMUMSS folder   ********
            REM cd ..

        REM ) else (
            REM echo.
            REM echo.  %_zBRIGHTGREEN%No conflicting files to check%_zDEFAULT%
            REM echo.
        REM )
    REM )
REM )

REM if !_bCheckMODSconflicts! EQU 2 (
    REM echo.
    REM echo.%_zBRIGHTGREEN%^>^>^> Skipped Conflict Detection at user request%_zDEFAULT%
    REM echo.
    REM echo|set /p="%_INFO% Skipped Conflict Detection at user request">>"REPORT.lua" & echo.>>"REPORT.lua"
REM )
REM END::START_CONFLICT_DETECTION

echo.
echo.              %_zBLUEonYELLOW% ^>^>^> FINAL REPORT ^<^<^< %_zDEFAULT%
echo.            %_zBLUEonYELLOW% ^>^>^> See "REPORT.lua" ^<^<^< %_zDEFAULT%

echo.>>"REPORT.lua"
echo|set /p="%_INFO%                 >>> FINAL REPORT  <<<">>"REPORT.lua" & echo.>>"REPORT.lua"

REM rem for testing BUG detection only
REM echo. [[Extras\lua_x64\bin\lua.exe:]]

Call :LuaEndedOkREMOVE
set "location=bz18_ReportFailedScript.lua"
.\MODBUILDER\%_mLUA% ".\MODBUILDER\ReportFailedScript.lua" ".\\" ".\\MODBUILDER\\"
Call :LuaEndedOk

if defined _bErrorLoadingScript (
    echo.
    echo.  %_zBLACKonYELLOW% ^>^>^>  INTERRUPTED / INCOMPLETE PROCESSING DETECTED  ^<^<^< %_zDEFAULT%
    
    echo.>>"REPORT.lua"
    echo|set /p="%_INFO%     >>>  INTERRUPTED / INCOMPLETE PROCESSING DETECTED  <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
)

Call :LuaEndedOkREMOVE
set "location=bz4_CheckREPORTLOG.lua"
.\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckREPORTLOG.lua" ".\\" ".\\MODBUILDER\\" !_bCheckMODSconflicts!
Call :LuaEndedOk

echo.            %_zBLUEonYELLOW% ^>^>^> See "REPORT.lua" ^<^<^< %_zDEFAULT%

if [%_uOldMBINCompilerFlag%]==[Y] (
    if %_bNumberScripts% GTR 0 (
        echo.
        echo.%_zBRIGHTRED%============================================================================%_zDEFAULT%
        echo. %_zINVERSE%[NOTE] Some PAKs could not be decompiled by the current MBINCompiler      %_zDEFAULT%
        echo. %_zINVERSE%       Processing of .lua scripts is halted until those PAKs are removed  %_zDEFAULT%
        echo. %_zINVERSE%       from ModScript                                                     %_zDEFAULT%
        echo.%_zBRIGHTRED%============================================================================%_zDEFAULT%
        
        echo|set /p="[NOTE] Some PAKs could not be decompiled by the current MBINCompiler">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE] Processing of .lua scripts is halted until those PAKs are removed">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p="[NOTE] from ModScript">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
    )
)

if defined _bUNPACKED_DECOMPILED (
    echo.
    echo.     %_zWHITEonDARKCYAN% %_bNumberMBINs% MBIN^(s^) processed %_zDEFAULT%
    echo.     %_zWHITEonDARKCYAN% %_bGNumScriptsInPak% Script^(s^) found in PAK^(s^) %_zDEFAULT%
    echo.     %_zWHITEonDARKCYAN% %_bNumberPAKs% PAK^(s^)/MBIN^(s^) processed %_zDEFAULT%
    echo.       %_zWHITEonDARKCYAN% %_bGNumberFiles% file^(s^) found in PAK^(s^)/MBIN^(s^) %_zDEFAULT%
    
    if [!_bCheckVersionOfFiles!]==[Y] (
        if %_bGNumberFilesNoVersionInfo% GTR 0 (
            echo.       %_zWHITEonDARKCYAN% %_bGNumberFilesNoVersionInfo% file^(s^) having NO Version information %_zDEFAULT%
        )
    )
    echo.       %_zWHITEonDARKCYAN% %_bGNumberFilesDecompiled% file^(s^) decompiled %_zDEFAULT%
    if %_bNumberFilesCouldNotDecompile% GTR 0 (
        echo.       %_zWHITEonDARKCYAN% %_bNumberFilesCouldNotDecompile% file^(s^) could not be decompiled by any MBINCompiler version %_zDEFAULT%
    )
    if %_bGNumberFilesMissing% GTR 0 (
        echo.       %_zWHITEonDARKCYAN% %_bGNumberFilesMissing% file^(s^) missing the right MBINCompiler %_zDEFAULT%
        echo.          %_zBLACKonYELLOW%    Please report missing VERSION to AMUMSS developper, thanks.    %_zDEFAULT%
    )
    
    echo.>>"REPORT.lua"
    echo|set /p="%_INFO% %_bNumberMBINs% MBIN(s) processed">>"REPORT.lua" & echo.>>"REPORT.lua"
    echo|set /p="%_INFO% %_bGNumScriptsInPak% Script(s) found in PAK(s)">>"REPORT.lua" & echo.>>"REPORT.lua"
    echo|set /p="%_INFO% %_bNumberPAKs% PAK(s)/MBIN(s) processed">>"REPORT.lua" & echo.>>"REPORT.lua"
    echo|set /p="%_INFO%   %_bGNumberFiles% file(s) found in PAK(s)/MBIN(s)">>"REPORT.lua" & echo.>>"REPORT.lua"
    
    if [!_bCheckVersionOfFiles!]==[Y] (
        if %_bGNumberFilesNoVersionInfo% GTR 0 (
            echo|set /p="%_INFO%   %_bGNumberFilesNoVersionInfo% file(s) having NO Version information">>"REPORT.lua" & echo.>>"REPORT.lua"
        )
    )
    echo|set /p="%_INFO%   %_bGNumberFilesDecompiled% file(s) decompiled">>"REPORT.lua" & echo.>>"REPORT.lua"
    if %_bNumberFilesCouldNotDecompile% GTR 0 (
        echo|set /p="%_INFO%   %_bNumberFilesCouldNotDecompile% file(s) could not be decompiled by any MBINCompiler version">>"REPORT.lua" & echo.>>"REPORT.lua"
    )
    if %_bGNumberFilesMissing% GTR 0 (
        echo|set /p="%_INFO%   %_bGNumberFilesMissing% file(s) missing the right MBINCompiler">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p=".   [WARNING]     Please report missing VERSION to AMUMSS developper, thanks.">>"REPORT.lua" & echo.>>"REPORT.lua"
    )
    echo.>>"REPORT.lua"
    
    if [%_uOldMBIN%]==[Y] (
        echo.
        echo.   %_zBRIGHTRED%========================================================%_zDEFAULT%
        echo.    %_zINVERSE%[NOTE] An older version of MBINCompiler was used      %_zDEFAULT%
        echo.    %_zINVERSE%      or the MBIN file was never re-compiled          %_zDEFAULT%
        echo.    %_zINVERSE%      or the right MBINCompiler could not be found.   %_zDEFAULT%
        echo.    %_zINVERSE%      It means that one or more EXML are most likely  %_zDEFAULT%
        echo.    %_zINVERSE%      not compatible with the current version of NMS. %_zDEFAULT%
        if %_bNumberScripts% GTR 0 (
            echo. %_zINVERSE%      No PAK will be produced^^!                      %_zDEFAULT%
        )
        echo.   %_zBRIGHTRED%========================================================%_zDEFAULT%
        
        echo.>>"REPORT.lua"
        echo|set /p=".   [NOTE] An older version of MBINCompiler was used">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p=".   [NOTE] or the MBIN file was never re-compiled">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p=".   [NOTE] or the right MBINCompiler could not be found.">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p=".   [NOTE] It means that one or more EXML are most likely">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo|set /p=".   [NOTE] not compatible with the current version of NMS.">>"REPORT.lua" & echo.>>"REPORT.lua"
        if %_bNumberScripts% GTR 0 (
            echo|set /p=".   [NOTE] No PAK will be produced^!">>"REPORT.lua" & echo.>>"REPORT.lua"
        )
        echo.>>"REPORT.lua"
    )
    
    echo.
    if %_bNumberPAKs% GTR 0 (
        echo. %_zBLACKonYELLOW%                                                                                                             %_zDEFAULT%
        echo. %_zBLACKonYELLOW% ^>^>^> You can examine the content of the PAKs in the TOOLS\UNPACKED_DECOMPILED_PAKs folder under the PAK name %_zDEFAULT%
        echo. %_zBLACKonYELLOW%                                                                                                             %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW% ^>^>^> The content of the LAST PAK is also in ModScript's EXTRACTED_PAK and EXMLFILES_PAK folders              %_zDEFAULT%
        REM echo. %_zBLACKonYELLOW%                                                                                                             %_zDEFAULT%
        
        echo|set /p="%_INFO% You can examine the content of the PAKs in the TOOLS\UNPACKED_DECOMPILED_PAKs folder under the PAK name">>"REPORT.lua" & echo.>>"REPORT.lua"
        echo.>>"REPORT.lua"
        REM echo|set /p="%_INFO% The content of the LAST PAK is also in ModScript's EXTRACTED_PAK and EXMLFILES_PAK folders">>"REPORT.lua" & echo.>>"REPORT.lua"
        REM echo.>>"REPORT.lua"
    )
)

REM get time to process
if defined _bStartTime (
    Call :LuaEndedOkREMOVE
    set "location=bz3_EndTime.lua"
    .\MODBUILDER\%_mLUA% ".\MODBUILDER\EndTime.lua" ".\\" ".\\MODBUILDER\\"
    Call :LuaEndedOk
    
    Call :LuaEndedOkREMOVE
    set "location=bz2_DiffTime.lua"
    .\MODBUILDER\%_mLUA% ".\MODBUILDER\DiffTime.lua" ".\\" ".\\MODBUILDER\\" "(AMUMSS %_CurrentVersion%)"
    Call :LuaEndedOk
)

REM echo.A: %TIME%

REM if defined _min_subprocess (
    REM echo.################ IN DEBUG MODE ################
    REM echo.
    REM if defined _mDEBUG (
        REM set _
        REM echo.%_zDEFAULT%
        REM echo. ********* Ran with these arguments *********
        REM set -
    REM )
    REM echo.%_zDEFAULT%
REM )

If defined _mGlobalRepl (
    Call :LuaEndedOkREMOVE
    set "location=bz1_CheckGlobalReplacements.lua"
    .\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckGlobalReplacements.lua" ".\\" ".\\MODBUILDER\\"
    Call :LuaEndedOk
)

REM echo.B: %TIME%

REM cleanup %_mLUA% errors
del /f /q .\MODBUILDER\LuaEndedOk.txt 1>NUL 2>NUL
del /f /q LuaEndedOk.txt 1>NUL 2>NUL
REM end cleanup %_mLUA% errors

REM if exist "LuaEndedOk.txt" (
    REM echo. LuaEndedOk.txt in main folder
    REM pause
REM )

REM if exist "%_bNMS_FOLDER%\GAMEDATA\MODS\*.pak" (
    REM echo. %_zBRIGHTRED% --- You have some .pak files in GAMEDATA\MODS folder --- %_zDEFAULT%
    REM echo. %_zBRIGHTRED% ---   Move those .pak files to GAMEDATA\PCBANKS\MODS --- %_zDEFAULT%
    REM echo. %_zBRIGHTRED% ---     Otherwise, NMS will not use those mods       --- %_zDEFAULT%
    REM echo.
REM )

if exist "%_bNMS_PCBANKS_FOLDER%DISABLEMODS.TXT" (
    echo. %_zBRIGHTRED% --- DISABLEMODS.TXT still exist in your PCBANKS folder --- %_zDEFAULT%
    echo. %_zBRIGHTRED% ---   Delete/Rename it or NMS will not use your mods   --- %_zDEFAULT%
)

if defined _mDEV (
    echo. %gcWARNING% USING LoadAndExecuteModScript_DEV %_zDEFAULT%
)

if not defined _mDEBUG (
    set "command=cmd /c Del /f /q /s "*.luax" 1>NUL 2>NUL"
    rem /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
    START "" /MIN "!command!"
)
REM echo.C: %TIME%

REM echo.^>^>^> Backing up %_zBRIGHTGREEN%REPORT.lua...%_zDEFAULT%
REM set mytime=%time::=.%
REM xcopy /y /h /i /j /c "REPORT.lua" ".\TOOLS\REPORTS_BACKUP\REPORT_%date%_%mytime%.lua*" 1>NUL 2>NUL

echo. Saving backup REPORT file...
.\MODBUILDER\%_mLUA% ".\MODBUILDER\CopyREPORT.lua"

REM echo.%_zBLACKonYELLOW% === PRESS ANY KEY and THIS window will close shortly after cleaning log.lua === %_zDEFAULT%
REM echo.%_zBLACKonYELLOW% === THIS window will close shortly after cleaning log.lua === %_zDEFAULT%

REM if not defined _mDEBUG (
    REM REM echo.Pause before exit
    REM pause
REM )

REM pause >nul
REM echo. One moment...

:LASTCHANCE
REM echo.D0: %TIME%

set "_AMUMSS_PATH=%CD%"
set "command=%_AMUMSS_PATH%\MODBUILDER\buildmod_update.bat"

if exist .\MODBUILDER\NEW_BUILDMOD.bat (
    echo.
    rem echo. %_zBRIGHTRED% Updating BUILDMOD.bat:  This window will close shortly, please wait... %_zDEFAULT%
    echo. %_zBRIGHTRED% Updating BUILDMOD.bat %_zDEFAULT%

	rem /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
	START "" /MIN "%command%"
REM ) else (
    REM echo. %_zBRIGHTRED% BUILDMOD.bat is latest %_zDEFAULT%	
)

REM echo. Saving Log files...
REM if [%_SOUND%]==[Y] (
    REM echo. 
REM )

REM echo.D1: %TIME%

rem DO NOT USE: takes very long to exit
rem exit /b

goto :eof


rem *****************************************************************************************
rem               --------------------- WE ARE DONE ---------------------
rem *****************************************************************************************

rem --------------------------------------------
rem subroutine section starts below

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
:DEV_MODE_INFO
    echo.
        echo. %_zBGintense%                                           %_zDEFAULT%
    if [%_DEV_MODE%]==[F] (echo.      ^>^>^>     Using FULL mode     ^<^<^<)
    if [%_DEV_MODE%]==[D] (echo.   ^>^>^>     Using DEVELOPMENT mode     ^<^<^<)
    if [%_DEV_MODE%]==[L] (echo.       ^>^>^>     Using LEAN mode     ^<^<^<)
        echo. %_zBGintense%                                           %_zDEFAULT%
    echo.
    EXIT /B
    
rem --------------------------------------------
REM :Cleaning_MXML_Helper
    REM set "_bCount=0"
    REM :RETRY4
    REM if !_bCount! GTR 1000 (
        REM echo.   xxxxx [WARNING] Problem cleaning folder 'TOOLS\MXML_Helper' xxxxx
        REM goto :PROBLEM_FOLDER
    REM )
    
    REM SET /A "_bCount=_bCount+1"
    REM Del /f /q /s ".\TOOLS\MXML_Helper\*.*" 1>NUL 2>NUL
    REM if exist ".\TOOLS\MXML_Helper" (
        REM rd /s /q ".\TOOLS\MXML_Helper" 2>NUL
        REM goto :RETRY4
    REM )
    REM REM mkdir "TOOLS\MXML_Helper" 1>NUL 2>NUL
    REM mkdir "TOOLS\MXML_Helper\MODDED" 1>NUL 2>NUL
    REM mkdir "TOOLS\MXML_Helper\ORG_MXML" 1>NUL 2>NUL
    REM REM mkdir "TOOLS\MXML_Helper\EXTRACTED"
    REM REM echo. CEH_4
    REM REM pause
    REM EXIT /B
    
rem --------------------------------------------
:Cleaning_EXML_Helper_OLD
    set "_bCount=0"
    :RETRY4
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem cleaning folder 'TOOLS\EXML_Helper' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s ".\TOOLS\EXML_Helper\*.*" 1>NUL 2>NUL
    if exist ".\TOOLS\EXML_Helper" (
        rd /s /q ".\TOOLS\EXML_Helper" 2>NUL
        goto :RETRY4
    )
    EXIT /B
    
    
rem --------------------------------------------
:Cleaning_TEMP_DECOMPILED
    set "_bCount=0"
    :RETRY5
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem cleaning folder 'MODBUILDER\_TEMP_DECOMPILED' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s ".\_TEMP\DECOMPILED\*.*" 1>NUL 2>NUL
    if exist ".\_TEMP\DECOMPILED" (
        rd /s /q ".\_TEMP\DECOMPILED" 2>NUL
        goto :RETRY5
    )
    rem DO NOT create _TEMP\DECOMPILED
    EXIT /B
    
rem --------------------------------------------
:Cleaning_MapFileTrees
    Del /f /q "..\TOOLS\MapFileTrees\*.*" 1>NUL 2>NUL
    Del /f /q "..\TOOLS\FileStructures\*.*" 1>NUL 2>NUL
    ECHO. >ResetMapFileTreeDone.txt
    EXIT /B
    
rem --------------------------------------------
:Cleaning_SavedSections
    Del /f /q /s "..\TOOLS\SavedSections\*.*" 1>NUL 2>NUL
    EXIT /B
    
rem --------------------------------------------
:Cleaning_EXTRACTED_PAK
    set "_bCount=0"
    :RETRY7
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem cleaning folder 'ModScript\EXTRACTED_PAK' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s "EXTRACTED_PAK\*.*" 1>NUL 2>NUL
    if exist "EXTRACTED_PAK" (
        rd /s /q "EXTRACTED_PAK" 1>NUL 2>NUL
        goto :RETRY7
    )
    rem DO NOT create ModScript\EXTRACTED_PAK
    EXIT /B
    
rem --------------------------------------------
:Cleaning_EXMLFILES_PAK
    set "_bCount=0"
    :RETRY8
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem Cleaning folder 'ModScript\EXMLFILES_PAK' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s "EXMLFILES_PAK\*.*" 1>NUL 2>NUL
    if exist "EXMLFILES_PAK" (
        rd /s /q "EXMLFILES_PAK" 1>NUL 2>NUL
        goto :RETRY8
    )
    rem DO NOT create ModScript\EXMLFILES_PAK
    EXIT /B
    
rem --------------------------------------------
:Cleaning_EXMLFILES_CURRENT
    set "_bCount=0"
    :RETRY9
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem Cleaning folder 'ModScript\EXMLFILES_CURRENT' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s "EXMLFILES_CURRENT\*.*" 1>NUL 2>NUL
    if exist "EXMLFILES_CURRENT" (
        rd /s /q "EXMLFILES_CURRENT" 1>NUL 2>NUL
        goto :RETRY9
    )
    rem DO NOT create ModScript\EXMLFILES_CURRENT
    EXIT /B
    
rem --------------------------------------------
:Cleaning_EXTRACTED_SOURCE
    set "_bCount=0"
    :RETRY10
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem Cleaning folder 'ModScript\EXTRACTED_SOURCE' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s "EXTRACTED_SOURCE\*.*" 1>NUL 2>NUL
    if exist "EXTRACTED_SOURCE" (
        rd /s /q "EXTRACTED_SOURCE" 1>NUL 2>NUL
        goto :RETRY10
    )
    rem DO NOT create ModScript\EXTRACTED_SOURCE
    EXIT /B
    
rem --------------------------------------------
:Cleaning_CREATEDMODS
    set "_bCount=0"
    :RETRY11
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem Cleaning folder 'CreatedMods' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s "CreatedMods\*.*" 1>NUL 2>NUL
    if exist "CreatedMODS" (
        rd /s /q "CreatedMods" 1>NUL 2>NUL
        goto :RETRY11
    )
    mkdir ".\CreatedMODS\" 1>NUL 2>NUL
    EXIT /B
    
rem --------------------------------------------
:Cleaning_TOOLS\MODDER_Helper
    set "_bCount=0"
    :RETRY12
    if !_bCount! GTR 100 (
        echo.   xxxxx [WARNING] Problem Cleaning folder 'TOOLS\MODDER_Helper' xxxxx
        goto :PROBLEM_FOLDER
    )
    
    SET /A "_bCount=_bCount+1"
    Del /f /q /s "TOOLS\MODDER_Helper\*.*" 1>NUL 2>NUL
    if exist "TOOLS\MODDER_Helper" (
        rd /s /q "TOOLS\MODDER_Helper" 1>NUL 2>NUL
        goto :RETRY12
    )
    mkdir ".\TOOLS\MODDER_Helper\" 1>NUL 2>NUL
    EXIT /B
    
rem --------------------------------------------
:DOPAUSE
    if defined _mPAUSE (
        echo.******
        pause
        echo.******
    )
    EXIT /B
    
rem --------------------------------------------
:LuaEndedOk
    if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
        echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
        echo.          From bzrunM.BAT %location%>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
        echo.    [[BUG]] lua.exe generated an [ERROR]... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
        echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
        echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
    )
    EXIT /B
    
rem --------------------------------------------
:LuaEndedOkREMOVE
    Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
    Del /f /q "%_bMASTER_FOLDER_PATH%LuaEndedOK.txt" 1>NUL 2>NUL
    EXIT /B
    
rem --------------------------------------------
:SWITCH_COMPILER
    if [%_GameVersion%]==[P] (
        copy /Y /B "MBINCompiler.public.exe" "MBINCompiler.exe" >nul
        
        Del /f /q "MBINCompilerVersion.txt" 1>NUL 2>NUL
        MBINCompiler.exe version -q >>MBINCompilerVersion.txt
        set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
        set "_bMBINCompilerCurrentVersion=!_bMBINCompilerVersion!"
        
        if exist "VersionPublic.txt" (
            echo.      - Using 'Public' MBINCompiler %_zBRIGHTGREEN%!_bMBINCompilerVersion!%_zDEFAULT%...
        ) else (
            echo.      - NOW using 'Public' MBINCompiler %_zBRIGHTGREEN%!_bMBINCompilerVersion!%_zDEFAULT%...
        )
    ) else (
        copy /Y /B "MBINCompiler.latest.exe" "MBINCompiler.exe" >nul
        
        Del /f /q "MBINCompilerVersion.txt"  1>NUL 2>NUL
        MBINCompiler.exe version -q >>MBINCompilerVersion.txt
        set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
        set "_bMBINCompilerCurrentVersion=!_bMBINCompilerVersion!"
        
        if not exist "VersionPublic.txt" (
            echo.      - Using 'most recent' MBINCompiler %_zBRIGHTGREEN%!_bMBINCompilerVersion!%_zDEFAULT%...
        ) else (
            echo.      - NOW using 'most recent' MBINCompiler %_zBRIGHTGREEN%!_bMBINCompilerVersion!%_zDEFAULT%...
        )
    )
    :ENDSWITCH_COMPILER
    EXIT /B
    
rem --------------------------------------------
:MBINCompilerUPDATE
    rem ****************************  start MBINCompiler.exe update section  ******************************
    rem ******   Currently IN MODBUILDER   ********
    echo.
    if not exist "MBINCompiler.exe" (
        echo. MBINCompiler.exe DOES NOT EXIST
        Del /f /q ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
        echo.^>^>^> Fetching MBINCompiler files on the web...
        goto :RETRY_MBINCompiler
    )
    
    if not exist "libMBIN.latest.dll" (
        echo. libMBIN.dll DOES NOT EXIST
        Del /f /q ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
        echo.^>^>^> Fetching MBINCompiler files on the web...
        goto :RETRY_MBINCompiler
    )
    
    Del /f /q "MBINCompilerVersion.txt" 1>NUL 2>NUL
    MBINCompiler.exe version -q >>MBINCompilerVersion.txt
    set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
    
    REM echo.^>^>^> Your current MBINCompiler is version: %_zBRIGHTGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
    
    REM set /p _bMBINCompilerVersionOLD=<MBINCompilerVersion.txt
    
    if [%-AutoUpdateMBinCompiler%]==[N] goto :END_MBINCompilerUPDATE
    
    REM REM in case this is a new install over an existing older one, force update
    REM if not exist "MBINCompiler.public.exe" (
        REM echo. MBINCompiler.public.exe DOES NOT EXIST
        REM Del /f /q /s ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
        REM echo.^>^>^> Fetching MBINCompiler on the web...
        REM goto :RETRY_MBINCompiler
    REM )
    
    if [%-AutoUpdateMBinCompiler%]==[ASK] goto :AskUpdateMBinCompiler
    if [%-AutoUpdateMBinCompiler%]==[] goto :AskUpdateMBinCompiler
    if [%-AutoUpdateMBinCompiler%]==[Y] goto :RETRY_MBINCompiler
    if [%-AutoUpdateMBinCompiler%]==[N] goto :END_MBINCompilerUPDATE
    
    echo.==^> BAD OPTION VALUE for '-AutoUpdateMBinCompiler' [%-AutoUpdateMBinCompiler%], please correct!
    echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
    pause
    
    :AskUpdateMBinCompiler
    echo.
    CHOICE /c:yn /t 30 /d y /m " %_zBLACKonYELLOW% ??? Do you want to UPDATE MBINCompiler.exe, if it is available, (default Y in 30 seconds) %_zDEFAULT%"
    if %ERRORLEVEL% EQU 2 goto :END_MBINCompilerUPDATE
    
    REM :SIMPLE_MODE1
    REM echo.
    REM REM echo.^>^>^> %_bB% Calling MBINCompilerDownloader.bat: getting latest MBINCompiler from Web
    REM echo.^>^>^> Getting latest MBINCompiler from Web...
    
    :RETRY_MBINCompiler
    CALL MBINCompilerDownloader.bat
    
    REM :CONTINUE_EXECUTION2
    if not exist "MBINCompiler.exe" (
        REM Del /f /q /s ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
        REM goto :RETRY_MBINCompiler
        echo.***** MISSING MBINCompiler.exe: AMUMSS cannot work.  Terminating batch until corrected.
        echo.***** Probable cause: anti-virus, make exception to AMUMSS main folder and restore blocked files
        echo.***** or: problem with internet
        pause
        exit
    )
    
    Del /f /q "MBINCompilerVersion.txt" 1>NUL 2>NUL
    MBINCompiler.exe version -q >>"MBINCompilerVersion.txt"
    set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
    
    if [%_bMBINCompilerVersion%]==[] (
        echo.
        echo.%gcERROR%^>^>^> [ERROR] MBINCompiler.exe cannot execute.  Probable cause: .net%_MasterDOTNET% DESKTOP runtime x64 is missing %_zDEFAULT%
        echo.
        echo.  %_zBLACKonYELLOW%                                                                       %_zDEFAULT%
        echo.  %_zBLACKonYELLOW% If NOT already installed:                                             %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%   .NET %_MasterDOTNET% Desktop latest version MUST be installed before continuing.  %_zDEFAULT%
        echo.  %_zBLACKonYELLOW% Otherwise, something else is preventing MBINCompiler from executing.  %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                       %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%    goto 'https://dotnet.microsoft.com/en-us/download/dotnet/%_MasterDOTNET%.0'      %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%      and select the '.NET Desktop Runtime %_MasterDOTNET%.?.?? Windows x64'         %_zDEFAULT%
        echo.  %_zBLACKonYELLOW%                                                                       %_zDEFAULT%
        echo.
        echo|set /p="[ERROR] MBINCompiler.exe cannot execute.  Probable cause: .net%_MasterDOTNET% x64 DESKTOP runtime is missing">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        echo.>>"..\REPORT.lua"
        pause
        exit
    )
    
    REM if NOT [%_bMBINCompilerVersionOLD%]==[%_bMBINCompilerVersion%] (
        REM echo.
        REM echo.^>^>^> Your new MBINCompiler is version: %_zBRIGHTGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
        REM echo|set /p="%_INFO% Your new MBINCompiler is version: %_bMBINCompilerVersion%">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
        REM echo.>>"..\REPORT.lua"
    REM REM ) else (
        REM REM echo.
        REM REM echo.^>^>^> MBINCompiler is still version: %_zBRIGHTGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
    REM )
    rem ****************************  end MBINCompiler.exe update section  ******************************
    
    :END_MBINCompilerUPDATE
    EXIT /B
    
rem --------------------------------------------
:CHECK_ExtraFilesToInclude
    rem --------------  Check if ExtraFilesToInclude are present ------------------------------
    SET "_bExtraFiles=0"
    
    FOR /r "%CD%\ModScript\GlobalMEFTI" %%G in (*.*) do (
        SET /A "_bExtraFiles=_bExtraFiles+1"
    )
    REM echo _bExtraFiles = %_bExtraFiles%
    SET "_bExtraFilesInPAK=N"
    if %_bExtraFiles% EQU 0 goto :END_CHECK_ExtraFilesToInclude
    
    if [%-UseExtraFilesInPAK%]==[ASK] goto :AskUseExtraFilesInPAK
    if [%-UseExtraFilesInPAK%]==[] goto :AskUseExtraFilesInPAK
    if [%-UseExtraFilesInPAK%]==[Y] (
        SET "_bExtraFilesInPAK=Y"
        goto :END_CHECK_ExtraFilesToInclude
    )
    if [%-UseExtraFilesInPAK%]==[N] goto :END_CHECK_ExtraFilesToInclude
    
    echo.==^> BAD OPTION VALUE for '-UseExtraFilesInPAK' [%-UseExtraFilesInPAK%], please correct!
    echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
    pause
    
    :AskUseExtraFilesInPAK
    echo.
    echo.^>^>^> There are Extra Files in ModScript\GlobalMEFTI folder.  If you INCLUDE them...
    echo.^>^>^>      *****  Remember, these files will OVERWRITE any existing ones in the created MODs  *****
    
    CHOICE /c:YN /m " %_zBLACKonYELLOW% ??? Do you want to include them in the created MOD %_zDEFAULT%"
    echo.
    if %ERRORLEVEL% EQU 2 goto :END_CHECK_ExtraFilesToInclude
    if %ERRORLEVEL% EQU 1 SET "_bExtraFilesInPAK=Y"
    
    echo|set /p="%_INFO% Extra Files in ModScript\GlobalMEFTI folder will be included in the MODs">>"REPORT.lua" & echo.>>"REPORT.lua"
    echo.>>"REPORT.lua"
    
    :END_CHECK_ExtraFilesToInclude
    EXIT /B
    
rem --------------------------------------------
:PAK_LISTsCREATION
    rem **************************  start PAK_LISTs creation section  ********************************
    echo.
    echo.^>^>^> Checking NMS PCBANKS PAK file list existence...
    
    REM check if we need to re-create the list
    CALL GetDateTimePCBANKS.bat
    
    if exist "pak_list.txt" SET "_gPAKlistExist=y"
    
    if defined _gPAKlistExist goto :Ask
    
    echo.
    echo.^>^>^> [INFO] NMS PCBANKS was updated...
    echo.
    set "_bNMSUpdated=1"
    
    :DoUpdate
    CALL PSARC_LIST_PAKS.BAT
    REM if defined _mVERBOSE (
        REM Call :LuaEndedOkREMOVE
        REM %_mLUA% FormatPAKlist.lua
        REM Call :LuaEndedOk
    REM )
    
    goto :NoNeedToAsk
    
    :Ask
    if NOT exist "..\TOOLS\NMS_FULL_pak_list.txt" goto :DoUpdate
    
    REM if NOT defined _mDEBUG goto :NoNeedToAsk
    
    if [%-RecreatePAKList%]==[ASK] goto :PAK_LISTsCREATION_2
    if [%-RecreatePAKList%]==[] goto :PAK_LISTsCREATION_2
    if [%-RecreatePAKList%]==[N] (
        set "_bRecreatePAKList=2"
        goto :NoNeedToAsk
    )
    if [%-RecreatePAKList%]==[Y] (
        echo. *** Option -RecreatePAKList set to Y ***
		set "_bRecreatePAKList=1"
        goto :RecreatePAKLIST
    )
    
    echo.==^> BAD OPTION VALUE for '-RecreatePAKList' [%-RecreatePAKList%], please correct!
    echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
    pause
    
    :PAK_LISTsCREATION_2
    echo.
    REM echo.^>^>^> If there was a NMS update, it is recommended to recreate this list
    CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to RECREATE the NMS PAK file list %_zDEFAULT%"
    if %ERRORLEVEL% EQU 2 set "_bRecreatePAKList=2"
    if %ERRORLEVEL% EQU 1 set "_bRecreatePAKList=1"
    
    :RecreatePAKLIST
    if %_bRecreatePAKList% EQU 1 (
        echo.
        CALL PSARC_LIST_PAKS.BAT
        REM if defined _mVERBOSE (
            REM Call :LuaEndedOkREMOVE
            REM %_mLUA% FormatPAKlist.lua
            REM Call :LuaEndedOk
            REM )
    )
    
    :NoNeedToAsk
    SET "_gPAKlistExist="
    SET "_bRecreatePAKList="
    rem **************************  end PAK_LISTs creation section  ********************************
    EXIT /B
    
rem --------------------------------------------
:UNPACKEDtoEXML
    rem ******   In UNPACKEDtoEXML: Currently IN ModScript   ********
    echo.

    rem set "_bCurrentPath=%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_PAK\"
    REM set "_bCurrentPath=%_bMASTER_FOLDER_PATH%TOOLS\UNPACKED_DECOMPILED_PAKs\%_bPAKname%\EXTRACTED_PAK\"
    
    REM echo._bDoingPAk is %_bDoingPAk%
    
    if DEFINED _bDoingPAk Del /f /q "REPORT_!_bPAKname!.txt" 1>NUL 2>NUL
    if DEFINED _bDoingPAk echo|set /p="REPORT for !_bPAKname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    
    rem checking if extra files are present and say so in report
    rem just have psarc list the content to the report
    if DEFINED _bDoingPAk echo|set /p="">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    REM if DEFINED _bDoingPAk echo|set /p="Pak content from psarc: ">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    if DEFINED _bDoingPAk "..\MODBUILDER\psarc.exe" list "%_bPaknamePATH%" >>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    if DEFINED _bDoingPAk echo|set /p="">>"REPORT_!_bPAKname!.txt"
    
    set "_bNumberFilesNoVersionInfo=0"
    set "_bNumberFiles=0"
    if [!_bCheckVersionOfFiles!]==[Y] (
        FOR /r "%_bCurrentPath%" %%G in (*.mbin.*) do (
            REM echo.With current MBINCompiler: %%G
            SET /A "_bNumberFiles=_bNumberFiles+1"
            set "_bG=%%G"
            set "_bNMSname=!_bG:%_bCurrentPath%=!"
            set "_gMBINVersion="
            Del /f /q "!_bCurrentPath!bMBINVersion.txt" 1>NUL 2>NUL
            rem get MBINCompiler version that compiled this MBIN
            ..\MODBUILDER\MBINCompiler.exe version -q "%%G">>"!_bCurrentPath!bMBINVersion.txt"
            set /p _gMBINVersion=<"!_bCurrentPath!bMBINVersion.txt"
            Del /f /q "!_bCurrentPath!bMBINVersion.txt" 1>NUL 2>NUL
            if [!_gMBINVersion!]==[0.0.0.0] (
                SET /A "_bNumberFilesNoVersionInfo=_bNumberFilesNoVersionInfo+1"
                echo.----- %_zBRIGHTRED%[NO VERSION INFO]%_zDEFAULT%    Never re-compiled: !_bNMSname!
                echo|set /p=".   [NO VERSION INFO]    Never re-compiled: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                if DEFINED _bDoingPAk echo|set /p=".   [NO VERSION INFO]    Never re-compiled: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
            ) else (
                if [!_gMBINVersion!]==[] (
                    echo.----- %_zBRIGHTRED%[NO VERSION INFO]%_zDEFAULT%    Could not check version: !_bNMSname!
                    echo|set /p=".   [NO VERSION INFO]    Could not check version: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                    if DEFINED _bDoingPAk echo|set /p=".   [NO VERSION INFO]    Could not check version: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
                ) else (
                    echo.----- [INFO] Compiled with version !_gMBINVersion!: !_bNMSname!
                    echo|set /p="%_INFO%     Compiled with version !_gMBINVersion!: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                    if DEFINED _bDoingPAk echo|set /p="%_INFO%     Compiled with version !_gMBINVersion!: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
                )
            )
        )
        echo.
    ) else (
        FOR /r "%_bCurrentPath%" %%G in (*.mbin.*) do (
            REM echo.With current MBINCompiler: %%G
            SET /A "_bNumberFiles=_bNumberFiles+1"
            set "_bG=%%G"
            set "_bNMSname=!_bG:%_bCurrentPath%=!"
        )
    )
    
    echo.^>^>^> Files to decompile: %_bNumberFiles%

    echo.^>^>^> Current MBINCompiler.exe %_zBRIGHTGREEN%working to decompile ALL .MBIN... %_zDEFAULT%*** BE PATIENT ***
    echo.>>"..\REPORT.lua"
    echo|set /p="%_INFO%Working to decompile ALL .MBIN with current MBINCompiler...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    if DEFINED _bDoingPAk echo|set /p="%_INFO%   Working to decompile ALL .MBIN...">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    
    set "_bCurrentPathMBIN=!_bCurrentPath:EXTRACTED_PAK\=!"

    if defined _pause (
        echo Z1: ModScript: current directory: !CD!
        pause
    )

    pushd !CD!
    cd !_bCurrentPathMBIN!

    if defined _pause (
        echo Z1: _bCurrentPathMBIN: current directory: !CD!
        pause
    )
    
    rem First we try our current MBINCompiler, extracting ALL to folder EXTRACTED_PAK
    REM THIS USED TO WORK
    REM ..\MODBUILDER\mbincompiler.exe convert -y -f -oEXML -d".\EXTRACTED_PAK" --exclude=";" --include="*.MBIN;*.MBIN.PC" ".\EXTRACTED_PAK" 1>NUL 2>NUL
    
    REM THIS CURRENTLY WORKS
    rem ..\MODBUILDER\mbincompiler.exe convert -y -f -oEXML -d".\EXTRACTED_PAK" --exclude=";" --include="*.MBIN;*.MBIN.PC" ".\EXTRACTED_PAK" 1>NUL 2>NUL

    "%_bMASTER_FOLDER_PATH%MODBUILDER\mbincompiler.exe" convert ".\EXTRACTED_PAK" -y -f -oEXML -d ".\EXMLFILES_PAK" --exclude=";" --include="*.MBIN;*.MBIN.PC" 1>NUL 2>NUL
    
	rem ALSO try
	"%_bMASTER_FOLDER_PATH%MODBUILDER\mbincompiler.exe" convert ".\EXTRACTED_PAK" -y -f -oMXML -d ".\EXMLFILES_PAK" --exclude=";" --include="*.MBIN;*.MBIN.PC" 1>NUL 2>NUL
    
    popd

    if defined _pause (
        echo Z2: ModScript: current directory: !CD!
        pause
    )
    
    echo.       %_zBRIGHTGREEN%Done 1st pass%_zDEFAULT% using 'current' MBINCompiler!
    echo.       %_zBRIGHTGREEN%2nd pass:%_zDEFAULT% Checking if some files still require an older MBINCompiler...
    echo.       %_zBRIGHTGREEN%IN REPORT.lua:%_zDEFAULT% ALL files were decompiled with %_zBRIGHTGREEN%MBINCompiler.%_bMBINCompilerVersion%%_zDEFAULT% unless as listed...
    echo.
    echo|set /p="%_INFO%Done 1st pass using 'current' MBINCompiler!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    echo|set /p="%_INFO%2nd pass: Checking if some files still require an older MBINCompiler, please wait...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    echo|set /p="%_INFO%ALL files were decompiled with MBINCompiler.%_bMBINCompilerVersion% unless as listed...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    echo.>>"..\REPORT.lua"

	if DEFINED _bDoingPAk echo|set /p="%_INFO%     ALL files were decompiled with MBINCompiler.%_bMBINCompilerVersion% unless as listed below...">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    
    SET "_uOldMBIN=N"
    
    SET "_bFileCount=0"
    SET "_bNumberFilesDecompiled=0"
    SET "_bNumberFilesMissing=0"
    SET "_bNumberFilesCouldNotDecompile=0"
    
    SET "_bLastCompiler="
    SET "_bBadLastCompilerUsed=N"

    echo. Done: ??? / %_bNumberFiles%

    FOR /r "%_bCurrentPath%" %%G in (*.mbin.*) do (
        SET /A "_bFileCount=_bFileCount+1"

        set "_bG=%%G"
        set /a "_bSize=%%~zG"
        if !_bSize! GTR 1024 (
            set /a "_bSize/=1024"
            if !_bSize! GTR 1024 (
                set /a "_bSize/=1024"
                set "_bSize=!_bSize! MB"
            ) else (
                set "_bSize=!_bSize! KB"
            )
        ) else (
            set "_bSize=!_bSize! bytes"
        )
        
        set "_bNMSname=!_bG:%_bCurrentPath%=!"
        
        set "_bname=%%~nxG"
        set "_bname=!_bname:.MBIN.PC=.MBIN!"
        set "_bname=!_bname:.MBIN=.EXML!"
        
        set "_gMBIN_FILE=!_bG:.MBIN.PC=.MBIN!"
        set "_gEXML_FILE_SOURCE=!_gMBIN_FILE:.MBIN=.EXML!"
        
        set "_gEXML_FILE_TARGET=!_gEXML_FILE_SOURCE:EXTRACTED_PAK=EXMLFILES_PAK!"
        
        set "_gDirTarget=!_bG:%%~nxG=!"
        set "_gDirTarget=!_gDirTarget:EXTRACTED_PAK=EXMLFILES_PAK!"

REM echo.              _bNMSname = !_bNMSname!
REM echo.                 _bname = !_bname!
REM echo.          _bCurrentPath = !_bCurrentPath!
REM echo.      _bCurrentPathMBIN = !_bCurrentPathMBIN!
REM echo.                    _bG = !_bG!
REM echo.     _gEXML_FILE_SOURCE = !_gEXML_FILE_SOURCE!
REM echo.     _gEXML_FILE_TARGET = !_gEXML_FILE_TARGET!
REM echo.            _gDirTarget = !_gDirTarget!

REM pause       

        set "_foundEXML="
        if exist !_gEXML_FILE_TARGET! (
            SET /A "_bNumberFilesDecompiled=_bNumberFilesDecompiled+1"
            REM echo _bNumberFilesDecompiled = [!_bNumberFilesDecompiled!]
            if [!_DEV_MODE!]==[F] (
				REM echo _DEV_MODE = [!_DEV_MODE!]
				REM echo _bNumberFiles = [!_bNumberFiles!]
				REM echo _bNumberFiles = [%_bNumberFiles%]
                REM echo. For !_bNMSname!
                echo.* !_bFileCount!/%_bNumberFiles%: !_bNMSname! ^(!_bSize!^)
                echo.      [SUCCESS] Decompiled with %_zBRIGHTGREEN%MBINCompiler.%_bMBINCompilerVersion%%_zDEFAULT%               
                echo|set /p="%_INFO%     SUCCESS: Decompiled with MBINCompiler.%_bMBINCompilerVersion%: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            )
            REM much too slow
			REM if DEFINED _bDoingPAk echo|set /p="%_INFO%     SUCCESS: Decompiled with MBINCompiler.%_bMBINCompilerVersion%: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

            set "_foundEXML=Y"
        ) 
        
        set /a "_bDone=_bFileCount%%2000"
        if !_bNumberFilesDecompiled! GTR 0 (
            if [!_bDone!]==[0] (
                echo. Done: !_bFileCount! / %_bNumberFiles%
            )
        )
        
		REM echo _foundEXML = [!_foundEXML!]
        if not defined _foundEXML (
            REM if [!_DEV_MODE!]==[F] (
                echo.* !_bFileCount!/%_bNumberFiles%: !_bNMSname! ^(!_bSize!^)
            REM )
                
            REM we need to try all MBINCompiler.exe
            REM maybe we will get lucky
            REM echo.With other MBINCompilers: %%G
            echo.
            SET "_uFound=N"
            SET "_bBadCompiler=N"
            SET "_bCurrentCompiler="
            
            if [%-UseLastCompiler%]==[N] (
                rem DO NOT RELY ON LAST COMPILER FOUND
                set "_bLastCompiler="
            )
            
            if not [!_bLastCompiler!]==[] (
                REM echo.%_zBRIGHTGREEN%^>^>^> %_bB% trying to decompile .mbin with last successful MBINCompiler...%_zDEFAULT%
                REM echo.
                                
                REM if [!_bBadLastCompilerUsed!]==[Y] (
                    REM echo.%_zUpOneLineErase%%_zUpOneLineErase%%_zBRIGHTGREEN%    Trying last used !_bLastCompiler!%_zDEFAULT%
                REM ) else (
                    echo.%_zUpOneLineErase%%_zBRIGHTGREEN%    Trying last used !_bLastCompiler!%_zDEFAULT%
                REM )
                SET "_gMBINVersion=!_bLastCompiler!"
                SET "_gMBINVersion=!_gMBINVersion:MBINCompiler.=!"
                
                pushd !CD!
                cd !_bCurrentPathMBIN!

                if [!_bBadLastCompilerUsed!]==[Y] (
            REM echo.^>^>^> R: Changed to !CD!
                   echo. & echo.|"%_bMASTER_FOLDER_PATH%MODBUILDER\Extras\MBINCompiler_OldVersions\!_bLastCompiler!" "%%G" 1>NUL 2>NUL

                ) else (
            REM echo.^>^>^> S: Changed to !CD!
                   "%_bMASTER_FOLDER_PATH%MODBUILDER\Extras\MBINCompiler_OldVersions\!_bLastCompiler!" "%%G" 1>NUL 2>NUL

                )
                mkdir "!_gDirTarget!" 1>NUL 2>NUL
                move /y "!_gEXML_FILE_SOURCE!" "!_gEXML_FILE_TARGET!" 1>NUL 2>NUL
                
                rem some versions of MBINCompiler do not play well and save result to _bCurrentPathMBIN instead of _gEXML_FILE_SOURCE
                move /y "!_bCurrentPathMBIN!!_bname!" "!_gEXML_FILE_TARGET!" 1>NUL 2>NUL
                popd
                
            ) else (
                if not defined _Reset (
                    echo.      Last MBINcompiler unknown, %_zWHITEonDARKCYAN% Trying them all...%_zDEFAULT%
                )
                set "_Reset="
            )
            
            if exist !_gEXML_FILE_TARGET! (
                set "_bCurrentCompiler=!_bLastCompiler!"
                if [!_uOldMBINCompilerFlag!]==[N] (
                    set "_uOldMBINCompilerFlag=Y"
                    set "_uOldMBIN=Y"
                )
                if [!_uFound!]==[N] (
                    SET "_uFound=Y"
                    if [!_bBadCompiler!]==[Y] (
                        set "_zUOLE=%_zUpOneLineErase%"
                    )
                    SET "_bBadCompiler=N"
                )
            ) else (
                echo.            Could %_zBRIGHTRED%NOT%_zDEFAULT% decompile. %_zWHITEonDARKCYAN% Trying alternate versions...%_zDEFAULT%
                echo.

                for /f "tokens=*" %%H in ('dir /b /O:-N "..\MODBUILDER\Extras\MBINCompiler_OldVersions\*.exe"') do (
                    REM USING MBINCompiler.exe.0.0.0.exe as a dummy to be able to detect if 1.0.1 was able to decompile
                    REM echo. This compiler: %%~nH
                    if exist !_gEXML_FILE_TARGET! (
                        if [!_uOldMBINCompilerFlag!]==[N] (
                            set "_uOldMBINCompilerFlag=Y"
                            set "_uOldMBIN=Y"
                        )
                        if [!_uFound!]==[N] (                
                            SET "_uFound=Y"

                            set "_bLastCompiler=!_bCurrentCompiler!"

                            if [!_bBadCompiler!]==[Y] (
                                set "_zUOLE=%_zUpOneLineErase%"
                            )
                            SET "_bBadCompiler=N"
                        )
                        
                        
                        
                    ) else (
                        SET "_bCurrentCompiler=%%~nH"
                        
                        if [!_bBadCompiler!]==[Y] (
                            echo.%_zUpOneLineErase%%_zUpOneLineErase%%_zGREEN%    Trying %%~nH%_zDEFAULT%
                        ) else (
                            echo.%_zUpOneLineErase%%_zGREEN%    Trying %%~nH%_zDEFAULT%
                        )
                        SET "_gMBINVersion=%%~nH"
                        SET "_gMBINVersion=!_gMBINVersion:MBINCompiler.=!"
                        REM echo.----- [INFO] version [!_gMBINVersion!]
                        
                        rem these do not return MBINCompiler version info
                        rem and ask to press a key, we auto-press a key
                        SET "_bBadCompiler=N"
                        if [!_gMBINVersion!]==[1.58.0] SET "_bBadCompiler=Y"
                        if [!_gMBINVersion!]==[1.57.0] SET "_bBadCompiler=Y"
                        if [!_gMBINVersion!]==[1.55.0] SET "_bBadCompiler=Y"
                        if [!_gMBINVersion!]==[1.53.0] SET "_bBadCompiler=Y"
                        if [!_gMBINVersion!]==[1.52.0] SET "_bBadCompiler=Y"
                        if [!_gMBINVersion!]==[1.38.3] SET "_bBadCompiler=Y"
                        
                        if not [!_gMBINVersion!]==[0.0.0] (
                            rem skip LastCompiler, no need to retry it
                            if not [!_gMBINVersion!]==[!_bLastCompiler!] (
                                set "_bBadLastCompilerUsed=!_bBadCompiler!"
                                
                                pushd !CD!
                                cd !_bCurrentPathMBIN!

                                if [!_bBadCompiler!]==[Y] (
REM echo.-----S: [INFO] version [!_gMBINVersion!]
                            REM echo.^>^>^> X: Changed to !CD!
                                   echo. & echo.|"%_bMASTER_FOLDER_PATH%MODBUILDER\Extras\MBINCompiler_OldVersions\%%~nH" "%%G" 1>NUL 2>NUL
                                    
                                ) else (
REM echo.-----T: [INFO] version [!_gMBINVersion!]
                            REM echo.^>^>^> Y: Changed to !CD!
                                   "%_bMASTER_FOLDER_PATH%MODBUILDER\Extras\MBINCompiler_OldVersions\%%~nH" "%%G" 1>NUL 2>NUL
                                    
                                )

                                mkdir "!_gDirTarget!" 1>NUL 2>NUL
                                move /y "!_gEXML_FILE_SOURCE!" "!_gEXML_FILE_TARGET!" 1>NUL 2>NUL
                                
                                rem some versions of MBINCompiler do not play well and save result to _bCurrentPathMBIN instead of _gEXML_FILE_SOURCE
                                move /y "!_bCurrentPathMBIN!!_bname!" "!_gEXML_FILE_TARGET!" 1>NUL 2>NUL
                                popd
                            )
                        ) else (
                            rem echo. _gMBINVersion = "0.0.0"
                            SET "_bBadLastCompilerUsed=N"
                        )
                    )
                )
            )
REM pause            
            
            if [!_uFound!]==[Y] (
                SET /A "_bNumberFilesDecompiled=_bNumberFilesDecompiled+1"
                REM if [!_DEV_MODE!]==[F] (
                    echo.%_zUpOneLineErase%!_zUOLE!      [SUCCESS] Decompiled with ------^> %_zBRIGHTRED%!_bCurrentCompiler!%_zDEFAULT%
                REM )
                    
                echo|set /p="%_INFO%     SUCCESS: Decompiled with ------> !_bCurrentCompiler!: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                if DEFINED _bDoingPAk echo|set /p="%_INFO%     SUCCESS: Decompiled with ------> !_bCurrentCompiler!: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

                set /a "_gMajorVersion=!_gMBINVersion:~0,1!"
                REM echo. _gMajorVersion = !_gMajorVersion!
                if !_gMajorVersion! LEQ 2 (
                    set "_Reset=Y"
                )
                        
            ) else (
                SET /A "_bNumberFilesCouldNotDecompile=_bNumberFilesCouldNotDecompile+1"
                set "_bLastCompiler="
                REM if [!_DEV_MODE!]==[F] (
                    echo.%_zUpOneLineErase%!_zUOLE!%gcWARNING%      [WARNING] No MBINCompiler could decompile this file%_zDEFAULT%
                REM )
                    
                echo|set /p="%_INFO%       [WARNING]:                 No MBINCompiler could decompile this file: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                if DEFINED _bDoingPAk echo|set /p="%_INFO%       [WARNING]:                 No MBINCompiler could decompile this file: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

REM echo. A:               _uFound = [!_uFound!]
REM echo. A:             _bNMSname = [!_bNMSname!]
REM echo. A:                _bname = [!_bname!]
REM echo. A:         _bCurrentPath = [!_bCurrentPath!]
REM echo. A:     _bCurrentPathMBIN = [!_bCurrentPathMBIN!]
REM echo. A:                   _bG = [!_bG!]
REM echo. A:    _gEXML_FILE_SOURCE = [!_gEXML_FILE_SOURCE!]
REM echo. A:    _gEXML_FILE_TARGET = [!_gEXML_FILE_TARGET!]
REM echo. A:           _gDirTarget = [!_gDirTarget!]

REM pause
            )
            set "_zUOLE="
            
            Del /f /q "..\MODBUILDER\Extras\MBINCompiler_OldVersions\*.log" 1>NUL 2>NUL
        )
    )
    rem %_zUpOneLine%%_zUpOneLine%
REM echo. %_zUpOneLine%%_zUpOneLineErase%
    rem echo.
    echo.%_zBRIGHTGREEN%^>^>^> Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files%_zDEFAULT%
    
    echo|set /p="%_INFO%   Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
    if DEFINED _bDoingPAk echo|set /p="%_INFO%   Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
    
    REM echo. Done: %_bFileCount% / %_bNumberFiles%

    rem calculate the number of scripts in this pak
    SET "_bNumScriptsInPak=0"
    FOR %%G in ("..\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK\*.lua") do (
        SET /A "_bNumScriptsInPak=_bNumScriptsInPak+1"
    )
    
    if %_bNumScriptsInPak% GTR 0 (
        if %_bNumScriptsInPak% EQU 1 (
            echo.%_zBRIGHTGREEN%^>^>^> Copied one script file %_zDEFAULT%
            echo|set /p="%_INFO%   Copied one script file">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            if DEFINED _bDoingPAk echo|set /p="%_INFO%   Copied one script file">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
        ) else (
            echo.%_zBRIGHTGREEN%^>^>^> Copied %_bNumScriptsInPak% script files %_zDEFAULT%
            echo|set /p="%_INFO%   Copied %_bNumScriptsInPak% script files">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            if DEFINED _bDoingPAk echo|set /p="%_INFO%   Copied %_bNumScriptsInPak% script files">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
        )
    )
    
    if %_bNumberFilesMissing% GTR 0 (
        if %_bNumberFilesMissing% GTR 1 (
            echo.%_zBRIGHTRED%^>^>^> [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report%_zDEFAULT%
            
            echo|set /p=".   [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            echo.>>"..\REPORT.lua"
            if DEFINED _bDoingPAk echo|set /p=".   [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
        ) else (
            echo.%_zBRIGHTRED%^>^>^> [WARNING] One file is missing the right version of MBINCompiler, please report%_zDEFAULT%
            
            echo|set /p=".   [WARNING] One file is missing the right version of MBINCompiler, please report">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            echo.>>"..\REPORT.lua"
            if DEFINED _bDoingPAk echo|set /p=".   [WARNING] One file is missing the right version of MBINCompiler, please report">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
        )
    )
    
    if %_bNumberFilesCouldNotDecompile% GTR 0 (
        if %_bNumberFilesCouldNotDecompile% GTR 1 (
            echo.%_zBRIGHTRED%^>^>^> [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler%_zDEFAULT%
            
            echo|set /p=".   [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            if DEFINED _bDoingPAk echo|set /p=".   [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
        ) else (
            echo.%_zBRIGHTRED%^>^>^> [WARNING] One file cannot be decompiled using any MBINCompiler%_zDEFAULT%
            
            echo|set /p=".   [WARNING] One file cannot be decompiled using any MBINCompiler">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
            if DEFINED _bDoingPAk echo|set /p=".   [WARNING] One file cannot be decompiled using any MBINCompiler">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
        )
    )
    
    if [!_bCheckVersionOfFiles!]==[Y] (
        if %_bNumberFilesNoVersionInfo% GTR 0 (
            REM echo.
            if %_bNumberFilesNoVersionInfo% GTR 1 (
                echo.%_zBRIGHTRED%^>^>^> [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information%_zDEFAULT%
                
                echo|set /p=".   [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                if DEFINED _bDoingPAk echo|set /p=".   [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
            ) else (
                echo.%_zBRIGHTRED%^>^>^> [WARNING] One file has NO version information%_zDEFAULT%
                
                echo|set /p=".   [WARNING] One file has NO version information">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
                if DEFINED _bDoingPAk echo|set /p=".   [WARNING] One file has NO version information">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
            )
        ) else (
            echo.>>"..\REPORT.lua"
        )
    ) else (
        echo.>>"..\REPORT.lua"
    )
    
    REM rem *******************  if any EXML files in EXTRACTED_PAK, move them to EXMLFILES_PAK
    REM echo.
    REM echo.%_zBRIGHTGREEN%^>^>^> Moving EXML files to !_bCurrentPath!EXMLFILES_PAK folder...%_zDEFAULT%
    
	rem THIS for /r loop would not work (!xyz! is not allowed for the path, %xyz% would be ok)
	REM FOR /r "!_bCurrentPath!EXTRACTED_PAK" %%G in (*.exml) do (
        REM set _gEXML_FILE=%%G
        REM set _gEXML_FILE=!_gEXML_FILE:EXTRACTED_PAK=EXMLFILES_PAK!
        REM rem NOTE: move command did not work
        REM xcopy /y /h "%%G" "!_gEXML_FILE!*" 1>NUL 2>NUL
    REM )
    
    REM if DEFINED _bDoingPAk echo.
    REM if DEFINED _bDoingPAk echo.^>^>^> Saving extracted files to TOOLS\UNPACKED_DECOMPILED_PAKs folder...
    
    REM rem doing it in two step so we can use the pak info in ModScript with a .lua
    REM rem when one exist (inside the pak or from the user)
    REM if DEFINED _bDoingPAk ROBOCOPY /e /j "EXMLFILES_PAK" "..\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" 1>NUL 2>NUL
    
    REM if DEFINED _bDoingPAk ROBOCOPY /j "EXTRACTED_PAK" "..\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" "*.lua" 1>NUL 2>NUL
    
    rem Del /f /q /s ".\EXTRACTED_PAK\*.exml" 1>NUL 2>NUL
    REM Del /f /q /s "!_bCurrentPath!*.exml" 1>NUL 2>NUL
    rem *******************  END: any EXML files in EXTRACTED_PAK, move them to EXMLFILES_PAK
    
    rem copy this pak report to its folder
    if DEFINED _bDoingPAk ROBOCOPY /j "." "..\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" "REPORT_!_bPAKname!.txt" 1>NUL 2>NUL
    
    SET /A "_bGNumberFiles=_bGNumberFiles+%_bNumberFiles%"
    SET /A "_bGNumberFilesDecompiled=_bGNumberFilesDecompiled+!_bNumberFilesDecompiled!"
    if [!_bCheckVersionOfFiles!]==[Y] (
        SET /A "_bGNumberFilesNoVersionInfo=_bGNumberFilesNoVersionInfo+!_bNumberFilesNoVersionInfo!"
    )
    SET /A "_bGNumberFilesMissing=_bGNumberFilesMissing+!_bNumberFilesMissing!"
    SET /A "_bGNumScriptsInPak=_bGNumScriptsInPak+!_bNumScriptsInPak!"

    if defined _pause (
        echo Z3: ModScript: current directory: !CD!
        pause
    )
    
    EXIT /B
    
rem --------------------------------------------
rem NOT USED
:GET_CURRENT_EXML_for_COMPARISON
    rem ******   Currently IN ModScript   ********
    REM @echo on
    echo.
    
    if not exist EXMLFILES_CURRENT (
        mkdir EXMLFILES_CURRENT 2>NUL
    ) else (
        CALL :Cleaning_EXMLFILES_CURRENT
        mkdir EXMLFILES_CURRENT 2>NUL
    )
    
    rem ******   Currently IN ModScript\EXMLFILES_CURRENT   ********
    cd EXMLFILES_CURRENT
    
    echo.%_zBRIGHTRED%=============================%_zDEFAULT%
    FOR /r "%CD%\ModScript\EXTRACTED_PAK" %%G in (*.MBIN) do (
        echo.Getting current EXML for %%~nxG
        
        set "_gMBIN_FILE=%%G"
        set "_gMBIN=!_gMBIN_FILE:.MBIN.PC=.MBIN!"
        set "_gEXML_FILE=!_gMBIN:.MBIN=.EXML!"
        if not exist "!_gEXML_FILE!" (
            mkdir "ModScript\EXTRACTED_SOURCE"
            
            rem ******   Currently IN MODBUILDER   ********
            cd ..\..\MODBUILDER
            
            CALL :EXTRACT_this !_gMBIN_FILE!
            
            rem ******   Currently IN ModScript   ********
            cd ..\ModScript
            
            echo.^>^>^> %_gG% MBINCompiler working...
            echo.----- [INFO] %%G
            rem was !CD!
            ..\MODBUILDER\MBINCompiler.exe ".\EXTRACTED_SOURCE\%%G" -y -f -d "\EXMLFILES_CURRENT\%%G\.." 1>NUL 2>NUL
            Call :LuaEndedOkREMOVE
            set "location=bz17_CheckMBINCompilerLOG.lua"
            ..\MODBUILDER\%_mLUA% ..\MODBUILDER\CheckMBINCompilerLOG.lua "..\\" "..\\MODBUILDER\\" "Decompiling %%G"
            Call :LuaEndedOk
            echo.
            REM echo."!CD!\DECOMPILED\!_gEXML_FILE!"
            REM echo."..\MOD\!_gEXML_FILE!*"
            REM xcopy /s /y /h "!CD!\DECOMPILED\!_gEXML_FILE!" "..\MOD\!_gEXML_FILE!*" 1>NUL 2>NUL
        )
    )
    echo.%_zBRIGHTRED%=============================%_zDEFAULT%
    
    rem ******   Currently IN ModScript   ********
    cd..
    CALL :Cleaning_EXTRACTED_SOURCE
    
    EXIT /B
    
rem --------------------------------------------
:EXTRACT_this
    rem ******   Currently IN MODBUILDER   ********
    
    Call :LuaEndedOkREMOVE
    set "location=bz16_LocateMOD_PAK_SOURCE.lua"
    %_mLUA% LocateMOD_PAK_SOURCE.lua %1
    Call :LuaEndedOk
    
    FOR /F "tokens=*" %%H in (..\ModScript\MOD_PAK_SOURCE.txt) do (
        if not exist "..\ModScript\EXTRACTED_SOURCE\%%H" (
            REM echo.
            echo.^>^>^> Getting %%H from NMS PCBANKS folder. Please wait...
            xcopy /s /y /h "%_bNMS_PCBANKS_FOLDER%%%H" "%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_SOURCE\" >NUL
        )
        REM echo.^>^>^> Looking to Extract required MBIN/EXML from %%H...
        ..\psarc.exe extract "%_bNMS_PCBANKS_FOLDER%%%H" "%1" --to="%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_SOURCE" -y 1>NUL 2>NUL
        if exist "%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_SOURCE\%1" (
            echo.^>^>^> Extracted MBIN/EXML from %%H...
            REM echo.^>^>^> %_gG% Found required MBIN
            goto :ENDEXTRACT
        )
    )
    :ENDEXTRACT_this
    EXIT /B
    
rem --------------------------------------------
:CheckBankSignatures
    echo. [%~2]
    echo. [%1] [!%1!]
    if exist "%~2" (
        echo. Does exist
        set "%1=Y"
    ) else (
        echo. Does not exist
    )
    :ENDCheckBankSignatures
    exit /B
    
rem --------------------------------------------
:HOW_MANY_LINES
    REM check how many lines to process for Conflict Detection
    SET /a "_Lines=0"
    For /f %%j in ('!_bSystem32!\Find.exe "" /v /c ^<%_fileToCheck%') Do set /a "_Lines=%%j"
    
    REM if !_bCheckMODSconflicts! EQU 1 goto :SkipSubtract
    REM if !_bCheckMODSconflicts! EQU 3 SET _subtractOne=Y
    if !_bCheckMODSconflicts! EQU 4 SET "_subtractOne=Y"
    
    if defined _subtractOne (
        rem one less for MODS
        set /a "_Lines=_Lines-1"
    )
    SET "_subtractOne="
    
    REM if defined _subtractTwo (
        REM rem two less for SCRIPTS
        REM set /a "_Lines=_Lines-2"
    REM )
    REM SET _subtractTwo=
    
    :SkipSubtract
    REM if !_Lines! GTR 10000 (
        REM echo.
        REM rem echo.  %_zBRIGHTGREEN%We have !_Lines! lines to process for Conflicts, it could add a few minutes to complete...%_zDEFAULT%
        REM CHOICE /c:ynms /m " %_zBLACKonYELLOW% ??? Do you want to check for conflicts ('Y'es, 'N'o OR in 'M'ODS folder only, 'S'cripts folder only)?%_zDEFAULT%"
        REM if !ERRORLEVEL! EQU 4 set "_bCheckMODSconflicts=4"
        REM if !ERRORLEVEL! EQU 3 set "_bCheckMODSconflicts=3"
        REM if !ERRORLEVEL! EQU 2 SET "_bCheckMODSconflicts=2"
        REM if !ERRORLEVEL! EQU 1 SET "_bCheckMODSconflicts=1"
    REM REM ) else (
        REM if !_Lines! GTR 0 (
            REM echo.
            REM if !_Lines! GTR 1 (
                REM echo.  %_zBRIGHTGREEN%We will check !_Lines! possible conflicting files%_zDEFAULT%
            REM ) else (
                REM echo.  %_zBRIGHTGREEN%We will check !_Lines! possible conflicting file%_zDEFAULT%
            REM )
        REM )
    REM )
    SET /A "_bGConflictLines=_bGConflictLines+!_Lines!"
    :END_HOW_MANY_LINES
    exit /B
    
rem --------------------------------------------
:CONFLICTDETECTION
    rem -------------   Conflict detection or not?  -------------
    if [%-CheckForModConflicts%]==[ASK] goto :ASK_CONFLICTDETECTION
    if [%-CheckForModConflicts%]==[] goto :ASK_CONFLICTDETECTION
    if [%-CheckForModConflicts%]==[N] (
        set "_bCheckMODSconflicts=2"
        goto :ENDCONFLICTDETECTION
    )
    if [%-CheckForModConflicts%]==[Y] (
        set "_bCheckMODSconflicts=1"
        goto :ENDCONFLICTDETECTION
    )
    if [%-CheckForModConflicts%]==[MODS] (
        set "_bCheckMODSconflicts=3"
        goto :ENDCONFLICTDETECTION
    )
    if [%-CheckForModConflicts%]==[M] (
        set "_bCheckMODSconflicts=3"
        goto :ENDCONFLICTDETECTION
    )
    if [%-CheckForModConflicts%]==[SCRIPTS] (
        set "_bCheckMODSconflicts=4"
        goto :ENDCONFLICTDETECTION
    )
    if [%-CheckForModConflicts%]==[S] (
        set "_bCheckMODSconflicts=4"
        goto :ENDCONFLICTDETECTION
    )
    
    echo.==^> BAD OPTION VALUE for '-CheckForModConflicts' [%-CheckForModConflicts%], please correct!
    echo.==^> see 'README-OPTIONS_DEFINITIONS.txt' for proper OPTION definitions
    pause
    
    :ASK_CONFLICTDETECTION
    echo.
    CHOICE /c:ynms /m " %_zBLACKonYELLOW% ??? Check your NMS MODS for conflict ('Y'es, 'N'o OR in 'M'ODS folder or 'S'cripts folder only)? %_zDEFAULT%"
    if %ERRORLEVEL% EQU 4 set "_bCheckMODSconflicts=4"
    if %ERRORLEVEL% EQU 3 set "_bCheckMODSconflicts=3"
    if %ERRORLEVEL% EQU 2 set "_bCheckMODSconflicts=2"
    if %ERRORLEVEL% EQU 1 set "_bCheckMODSconflicts=1"
    :ENDCONFLICTDETECTION
    EXIT /B
    
rem --------------------------------------------
