@echo off
set "_CCver=v0.99.5"
set "thisBAT=_Check_MODS_Status.bat"
title %thisBAT% %_CCver% --^> %CD%

rem turn colors ON for win 10 1903 and before
reg add HKCU\Console /V VirtualTerminalLevel /T REG_DWORD /D 0x00000001 /F /reg:64 1>NUL 2>NUL

REM enable color output
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "CurrentBuildHex=%%~b"
set /a "_bCurrentBuildDec=%CurrentBuildHex%"

rem nothing to do to get colors for > win 10 1803 (18362)
if %_bCurrentBuildDec% LEQ 18362 (
	if %_bCurrentBuildDec% LEQ 7601 (
		rem for win 7 and before, use ansicon.exe instead
		.\MODBUILDER\ansicon_x64\ansicon.exe -p 1>NUL 2>NUL
	REM ) else (
		REM rem turn colors ON for win 10 1903 and before
		REM reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f 1>NUL 2>NUL
	)
)

REM REM enable color output
REM rem NOT USED, won't work on win 7, use ansicon.exe instead
REM rem reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f 1>NUL 2>NUL

REM .\MODBUILDER\ansicon_x64\ansicon.exe -p 1>NUL 2>NUL

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

set "_zINVERSE=[7m"
set "_zDEFAULT=[0m"

set "_zUpOneLineErase=[F[K"
set "_zBGintense=[100m"

set "-UseColors=Y"
set "-UseColorConfig=Y"

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
set "_bSystem32=%SYSTEMROOT%\system32"

cd /D "%~dp0"

Del /f /q "MODS_Status.lua" 1>NUL 2>NUL

rem set "_bMASTER_FOLDER_PATH=%~dp0"
rem \ is required with %CD%
set "_bMASTER_FOLDER_PATH=%CD%\"

rem MASTER_FOLDER_PATH.txt is needed by certain functions
rem echo|set /p="%~dp0">MASTER_FOLDER_PATH.txt
echo|set /p="%~dp0">.\MODBUILDER\MASTER_FOLDER_PATH.txt

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

rem --------------   Installed OS_2: get Lua.exe  -----------------------------
rem since MBINCompiler can only be used on x64 now
if exist "!CD!\MODBUILDER\Extras\lua_x64\bin\lua.exe" set "_mLUA=Extras\lua_x64\bin\lua.exe"
if exist "!CD!\MODBUILDER\Extras\lua_x64\bin\luaS.exe" set "_mLUAS=Extras\lua_x64\bin\luaS.exe"
if exist "!CD!\MODBUILDER\Extras\lua_x64\bin\luaM.exe" set "_mLUAM=Extras\lua_x64\bin\luaM.exe"
set "_mLUAC=Extras\lua_x64\bin\luac.exe"

rem --------------  end Installed OS_2: get Lua.exe   -----------------------------
  
SET "_bDateTimeStart=  %DATE% %TIME% %thisBAT% starting^!"
echo.!_bDateTimeStart!

rem *********************  NOW IN AMUMSS folder  *******************

if exist WOPT_SERIALIZING.txt (set "_mSERIALIZING=Y")
if exist WOPT_DEBUG.txt (set "_mDEBUG=y")
if exist WOPT_ISxxx.txt (set "_mISxxx=Y")
if exist WOPT_PAUSE.txt (set "_mPAUSE=y")
if exist WOPT_VERBOSE_BATCH.txt (set "_mVERBOSE=y")
if exist WOPT_Wbertro.txt (set "_mWbertro=y")
if exist WOPT_GlobalRepl.txt (set "_mGlobalRepl=y")

SET /p _mCurrentVersion=<"MODBUILDER\AMUMSSVersion.txt"

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
IF %PROCESSOR_ARCHITECTURE% == x86 (
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
chcp >MODBUILDER\ActiveCodePage.txt

FOR /F "tokens=*" %%A IN ('CHCP') DO FOR %%B IN (%%~A) DO SET "_CodePage=%%B"

rem remove end dot for some version of German Windows XP and 7
if %_CodePage:~-1%==. (
	set "_CodePage=%_CodePage:~0,-1%"
)

echo.
echo.  %_zWHITEonDARKCYAN% ^>^>^> Note: Please make sure no %_zDEFAULT%%_zINVERSE% 'accented characters' %_zDEFAULT%%_zWHITEonDARKCYAN% are in AMUMSS path %_zDEFAULT%
rem **********************  end Active code page check  *************************

REM echo.
REM echo.%_zBRIGHTGREEN%  %thisBAT% %_CCver%%_zDEFAULT%

REM MODBUILDER\%_mLUA% -e print(_VERSION)>temp.txt
REM set /p _bVersionLua=<temp.txt
REM echo.%_zBRIGHTGREEN%  %_bVersionLua% custom version with lfs%_zDEFAULT%
REM Del /f /q "temp.txt" 1>NUL 2>NUL

REM if %_bCurrentBuildDec% GEQ 22000 (
	REM set "_bWinVer=%_bWinVer:10=11%"
REM )

REM if %_bOS_bitness%==64 (
	REM echo.%_zBRIGHTGREEN%  %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
REM ) else (
	REM echo.%_zBRIGHTGREEN%  %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
REM )

REM if defined _TestNet5 (
    REM echo.%_zBRIGHTGREEN%    %DotNet5%%_zDEFAULT%
REM )
REM if defined _TestNet6 (
    REM echo.%_zBRIGHTGREEN%    %DotNet6%%_zDEFAULT%
REM )
REM if defined _TestNet8 (
    REM echo.%_zBRIGHTGREEN%    %DotNet8%%_zDEFAULT%
REM )
REM MODBUILDER\%_mLUA% .\MODBUILDER\GetVersionInfo.lua ".\\" ".\\MODBUILDER\\" "Y"
REM set /p _bNMS_VERSIONID=<"MODBUILDER\NMS_versionId.txt" 1>NUL 2>NUL

REM rem DO NOT REMOVE
REM set "_bB="

REM echo.
REM echo.^>^>^> %_bB% Starting in !CD!

REM rem remove old report.txt
REM Del /f /q "REPORT.txt" 1>NUL 2>NUL

REM rem we are using this now
REM Del /f /q "REPORT.lua" 1>NUL 2>NUL

REM if exist "REPORT.lua" (
	REM echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW%             File "REPORT.lua" cannot be opened                %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW%     It may be that a previous cmd window is still open...     %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW%           probably from running:                              %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW%                      BUILDMOD / _%thisBAT%                   %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW% Please terminate those previous cmd window^(s^) and re-try      %_zDEFAULT%
	REM echo.  %_zBLACKonYELLOW%                                                               %_zDEFAULT%
	REM pause
	REM exit
REM )

REM rem **********************  start of NMS_FOLDER DISCOVERY section  *************************
REM rem try to find the NMS folder path
REM rem if the user gave a path, try to use it first
REM echo.
REM echo.^>^>^> %_bB% Checking Path to NMS_FOLDER...

REM rem *****************************************************
REM if not exist "CONFIG\NMS_FOLDER.txt" (
	REM rem we need to re-create it
	REM echo.
	REM REM echo.^>^>^>      Re-creating missing CONFIG\NMS_FOLDER.txt...
	REM REM copy /Y /B "MODBUILDER\NMS_FOLDER_BAK.txt" ".\CONFIG\NMS_FOLDER.txt" 1>NUL 2>NUL
	REM echo.   ===^>  PLEASE execute BUILDMOD.bat at least once before and re-run _%thisBAT%
	REM pause
	REM exit
REM )
REM rem *****************************************************

REM set /p _bNMS_FOLDER=<.\CONFIG\NMS_FOLDER.txt 1>NUL 2>NUL
REM echo !_bNMS_FOLDER!>test.txt
REM REM echo. A- [!_bNMS_FOLDER!]

REM set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"
REM REM echo. 0- [%_bNMS_PCBANKS_FOLDER%]

REM if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	REM echo. Current path does not work...
	REM for %%G in (1,2) do (
		REM if not defined _bFoundNMS (
			REM if %%G EQU 1 (
				REM rem NMS on Steam
				REM echo.   Trying NMS on Steam using registry
				REM set _bREGKEY="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 275850"
				REM set _bREGVAL="InstallLocation"
			REM )
			REM if %%G EQU 2 (
				REM rem NMS on GOG on 64bit
				REM echo.   Trying NMS on GOG on 64bit using registry
				REM set _bREGKEY="HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1446213994"
				REM set _bREGVAL="path"
			REM )
			
			REM rem for DEBUG
			REM REM REG QUERY !_bREGKEY! /v !_bREGVAL!
			REM set "_bvalue="
			REM FOR /F "usebackq skip=2 tokens=1,2*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
				REM set "_bvalue=%%C"
			REM )
			REM REM echo. E- !_bvalue!
			REM ECHO !_bvalue!>test.txt
			
			REM set /p _bNMS_FOLDER=<test.txt
			REM REM echo. B- [!_bNMS_FOLDER!]
			REM set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"
			REM REM echo. 1- [!_bNMS_PCBANKS_FOLDER!]
			REM if exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
				REM echo.
				REM echo.%_bB% Found Path to NMS_FOLDER...
				REM set "_bFoundNMS=y"
				REM goto :REG_EXPLORATION_DONE
			REM ) else (
				REM echo.      not here...
			REM )
		REM )
	REM )
	REM echo.   Registry research done...
REM ) else (
	REM set "_bFoundNMS=y"
REM )

REM :REG_EXPLORATION_DONE
REM echo.
REM if defined _bFoundNMS (
	REM copy /y "test.txt" "CONFIG\NMS_FOLDER.txt*" 1>NUL 2>NUL
REM ) else (
	REM echo.^>^>^> %_bB% Still looking to locate path to NMS_FOLDER...
	REM echo.
	REM set "_bvalue="
	
	REM set _bREGKEY="HKLM\SOFTWARE\WOW6432Node\Valve\Steam"
	REM set _bREGVAL="InstallPath"
	REM FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
		REM if [%%B]==[] (
			REM set "_bvalue=%%A"
		REM ) else (
			REM set "_bvalue=%%A %%B"
		REM )
	REM )
	REM ECHO !_bvalue!>test.txt
	REM set /p _bNMS_FOLDER=<test.txt
	REM set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"
	REM REM echo. 1- [!_bNMS_PCBANKS_FOLDER!]
	REM if exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
		REM echo.
		REM echo.%_bB% Found Path to NMS_FOLDER...
		REM copy /y "test.txt" "CONFIG\NMS_FOLDER.txt*" 1>NUL 2>NUL
	REM ) else (
		REM rem then NMS could be in a Steam Library folder
		REM ECHO !_bvalue!>test.txt
		REM echo.   Looking for Libraries in: [!_bvalue!]
		REM echo.
		
		REM Call :LuaEndedOkREMOVE
		REM set "location=bz15"
		REM MODBUILDER\%_mLUA% MODBUILDER\GetNMSFolder.lua "!_bvalue!" ".\\MODBUILDER\\"
		REM Call :LuaEndedOk
	REM )	
REM )

REM set "_bREGKEY="
REM set "_bREGVAL="
REM set "_bvalue="
REM set "_bFoundNMS="

REM set /p _bNMS_FOLDER=<CONFIG\NMS_FOLDER.txt
REM set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"

REM REM look for GamePass
REM if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	REM echo.   Looking for GAMEPASS No Man's Sky folder
	REM MODBUILDER\%_mLUA% .\MODBUILDER\GetGamePassPath.lua
REM )

REM set /p _bNMS_FOLDER=<CONFIG\NMS_FOLDER.txt
REM set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"

REM if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	REM echo.********************* PLEASE correct your path in CONFIG\NMS_FOLDER.txt, NMS game files not found ********************
	REM echo. Bad Path to: ["%_bNMS_PCBANKS_FOLDER%BankSignatures.bin"]
	REM echo. Found this PATH in [CONFIG\NMS_FOLDER.txt] "%_bNMS_FOLDER%"
	REM echo.%_zBRIGHTRED% ^>^>^> Your PATH in [CONFIG\NMS_FOLDER.txt] must be pointing to the folder containing 'GAMEDATA' %_zDEFAULT%
	REM echo.***** Terminating batch until corrected...
	REM pause
	REM exit
REM ) else (
	REM echo. %_zBLACKonYELLOW% Path to NMS_FOLDER is ^>^>^>%_zDEFAULT%%_zWHITEonDARKCYAN% GOOD %_zDEFAULT%%_zBLACKonYELLOW%^<^<^< game files found %_zDEFAULT%
REM )
REM cd /D "%~dp0"

REM echo.
REM echo.^>^>^> %_bB% Updating CONFIG\NMS_FOLDER.txt to "%_bNMS_FOLDER%"
REM copy /y "CONFIG\NMS_FOLDER.txt" "MODBUILDER\NMS_FOLDER_BAK.txt*" >NUL
REM Del /f /q "test.txt" 1>NUL 2>NUL
REM rem **********************  end of NMS_FOLDER DISCOVERY section  *************************

rem ************************************  SOME FOLDER preparation  ***********************
rem ********  doing some cleanup that Delete_this.txt cannot do
if exist ".\UNPACKED_DECOMPILED_PAKs" (
	move /y "UNPACKED_DECOMPILED_PAKs" ".\TOOLS\UNPACKED_DECOMPILED_PAKs" 1>NUL 2>NUL
)

if exist ".\NMSPE_Output" (
	move /y "NMSPE_Output" ".\TOOLS\NMSPE_Output" 1>NUL 2>NUL
)
rem ********  END: doing some cleanup that Delete_this.txt cannot do

if not exist ".\CONFIG\OUTDATED_CheckList.txt" (
    copy /Y /B ".\MODBUILDER\OUTDATED_CheckList_template.txt" ".\CONFIG\OUTDATED_CheckList.txt" >nul
)

if not exist "!CD!\ModScript" (
	mkdir "!CD!\ModScript\" 2>NUL
)

set "_DisableFolder=Disabled scripts and paks"
if not exist "!CD!\ModScript\%_DisableFolder%" (
	mkdir "!CD!\ModScript\%_DisableFolder%" 2>NUL
)

if not exist "!CD!\TOOLS\ModScriptCheck" (
	mkdir "!CD!\TOOLS\ModScriptCheck\" 2>NUL
)

if not exist "!CD!\TOOLS\SavedSections" (
	mkdir "!CD!\TOOLS\SavedSections\" 2>NUL
)

if not exist "!CD!\TOOLS\UNPACKED_DECOMPILED_PAKs" (
	mkdir "!CD!\TOOLS\UNPACKED_DECOMPILED_PAKs\" 2>NUL
)

if not exist "!CD!\MODBUILDER\_TEMP" (
	mkdir "!CD!\MODBUILDER\_TEMP\" 2>NUL
)

if not exist "!CD!\TOOLS\MapFileTrees" (
	mkdir "!CD!\TOOLS\MapFileTrees\" 2>NUL
)

if not exist "!CD!\TOOLS\FileStructures" (
	mkdir "!CD!\TOOLS\FileStructures\" 2>NUL
)

if not exist ".\ModBackups" (
    mkdir ".\ModBackups\" 2>NUL
)

rem set "prefix=________________"
set /p prefix=<".\MODBUILDER\ModBackups_prefix.txt"

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

if exist "MODBUILDER\Delete_this.txt" (
	FOR /F "delims=" %%G in (MODBUILDER\Delete_this.txt) do (
		if exist "%%G" (
			Del /f /q "%%G" 1>NUL 2>NUL
			RD "%%G"
		)
	)
	if not defined _mWbertro (
		Del /f /q "MODBUILDER\Delete_this.txt" 1>NUL 2>NUL
	)
)

rem ******************  Check for BUILDMOD_AUTO.bat  ***********************************
if not exist "BUILDMOD_AUTO.bat" (
	rem we need to re-create it
	echo.
	echo.^>^>^>      Re-created missing BUILDMOD_AUTO.bat...
	copy /Y /B "MODBUILDER\buildmod_auto.backup" ".\BUILDMOD_AUTO.bat" >nul
)
rem *****************************************************

rem **********************  Check for updates  *******************************************
if not exist "!CD!\MODBUILDER\UPDATE" (
	mkdir "!CD!\MODBUILDER\UPDATE\" 2>NUL
)

set "_INFO=^[INFO] "
set "_INFO="

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

del /f /q MBIN_PAKS.txt 1>NUL 2>NUL
echo|set /p="">MBIN_PAKS.txt
echo.>>"MBIN_PAKS.txt"

del /f /q MODS_pak_list.txt 1>NUL 2>NUL
echo|set /p="">MODS_pak_list.txt

del /f /q ModScript_pakContent_list.txt 1>NUL 2>NUL
echo|set /p="">ModScript_pakContent_list.txt

:START_CONFLICT_DETECTION
rem ******   NOW IN AMUMSS folder   ********
cd "%~dp0"

if exist MODBUILDER\_Check_MODS_Status_run.bat (
	rem Del /f /q bzrun.bat 1>NUL 2>NUL
	if "%ProgramFiles(x86)%" == "" (
		REM echo. running on 32-bit windows
		set "_Check_MODS_Status_run=x32"
		REM echo.        using _Check_MODS_Status_run.bat 32-bit
		REM echo.
		CALL MODBUILDER\_Check_MODS_Status_run.bat 2>&1 | (MODBUILDER\tee.exe MODS_Status.lua)
		REM echo.E0: %TIME%
	) else (
		REM echo. running on 64-bit windows
		if not exist "%SYSTEMROOT%\Sysnative\cmd.exe" (
			REM echo. hmm, cannot access 64-bit apps
			set "_Check_MODS_Status_run=x64"
			REM echo.        using _Check_MODS_Status_run.bat on 64-bit system
			REM echo.
			CALL MODBUILDER\_Check_MODS_Status_run.bat 2>&1 | (MODBUILDER\tee.exe MODS_Status.lua)
			REM echo.E1: %TIME%
		) else (
			set "_Check_MODS_Status_run=x64"
			REM echo.        using _Check_MODS_Status_run.bat 64-bit from 32-bit cmd
			REM echo.
			CALL "%SYSTEMROOT%\Sysnative\cmd.exe" /c MODBUILDER\_Check_MODS_Status_run.bat 2>&1 | (MODBUILDER\tee.exe MODS_Status.lua)
			REM echo.E2: %TIME%
		)
	)	
)

echo.            %_zBLACKonYELLOW% ^>^>^> See "MODS_Status.lua" ^<^<^< %_zDEFAULT%

REM cleanup %_mLUA% errors
del /f /q .\MODBUILDER\LuaEndedOk.txt 1>NUL 2>NUL
REM end cleanup %_mLUA% errors

rem needs to be standing alone
rem echo. Cleaning MODS_Status.lua...
cd TOOLS
set "command=Status_file_cleaner.bat"
rem START /b /WAIT "" /MIN "%command%"
START /b "Cleaning MODS_Status.lua file" /MIN "%command%"

echo.
echo. All Done
pause

REM exit
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
		echo.          From %thisBAT% %location%>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.    [BUG] lua.exe generated an [ERROR]... Please report MODS_Status.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT_MODS_Status.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
