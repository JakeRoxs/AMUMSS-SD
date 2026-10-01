@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

FOR /F "usebackq tokens=3,4,5" %%i IN (`REG query "hklm\software\microsoft\windows NT\CurrentVersion" /v ProductName`) DO (
    set "_bWinVer=%%i %%j %%k"
    set "_bWinNum=%%j"
)
set "nulString= "
if [%_bWinNum%]==[10] (
    set "nulString=1>NUL 2>NUL"
)

echo.
echo.%_zWHITEonDARKCYAN% Updating NMS's "GCMODSETTINGS.MXML" status... %_zDEFAULT%
echo.    on Windows %_bWinNum%

set /p _bNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt 1>NUL 2>NUL
set "_bNMS_Binaries_FOLDER=%_bNMS_FOLDER%\Binaries\"

set "_bNMS_SETTINGS_FOLDER=%_bNMS_Binaries_FOLDER%SETTINGS\"
set "_bNMS_GCMODSETTINGS=%_bNMS_SETTINGS_FOLDER%GCMODSETTINGS.MXML"

REM FOR %%? IN ("%_bNMS_GCMODSETTINGS%") DO (
    REM ECHO File Name Only       : %%~n?
    REM ECHO File Extension       : %%~x?
    REM ECHO Name in 8.3 notation : %%~sn?
    REM ECHO File Attributes      : %%~a?
    REM ECHO Located on Drive     : %%~d?
    REM ECHO File Size            : %%~z?
    REM ECHO Last-Modified Date   : %%~t?
    REM ECHO Drive and Path       : %%~dp?
    REM ECHO Drive                : %%~d?
    REM ECHO Fully Qualified Path : %%~f?
    REM ECHO FQP in 8.3 notation  : %%~sf?
    REM ECHO Location in the PATH : %%~dp$PATH:?
REM )

REM pushd %_bNMS_SETTINGS_FOLDER%
REM powershell -Command "& {Get-ItemPropertyValue -Path "GCMODSETTINGS.MXML" -Name LastWriteTime;}"
REM popd
REM pause

echo.   Starting: %TIME%

rem get LastWriteTime of GCMODSETTINGS.MXML
pushd %_bNMS_SETTINGS_FOLDER%
FOR /f "usebackq delims=" %%I IN (`powershell.exe "& {Get-ItemPropertyValue -Path "GCMODSETTINGS.MXML" -Name LastWriteTime;}"`) do set "modif_time=%%I"
popd
REM echo. %modif_time% at %TIME%

REM if exist %_bNMS_Binaries_FOLDER%NMS.exe (
	REM tasklist /FI "IMAGENAME eq steam.exe"  /V /Fo CSV 2>NUL|"%__AppDir__%find.exe" /I "steam.exe">NUL&&(set "STEAMrunning=opened")||set "STEAMrunning=closed"
REM )
REM echo.AFTER checking if steam.exe is already running: %TIME%

if exist %_bNMS_Binaries_FOLDER%NMS.exe (
	tasklist /FI "IMAGENAME eq NMS.exe"  /V /Fo CSV 2>NUL|"%__AppDir__%find.exe" /I "NMS.exe">NUL&&(set "NMSrunning=opened")||set "NMSrunning=closed"
)
echo.      AFTER checking NMS.exe is already running: %TIME%

if [!NMSrunning!]==[opened] (
    echo.      ^>^>^> NMS.exe is already running, assuming GCMODSETTINGS.MXML is up-to-date
    REM CHOICE /c:yn /m " !_zBLACKonYELLOW! ??? NMS.exe is running.  Do you want to restart it !_zDEFAULT!"
    REM if !ERRORLEVEL! EQU 1 (
        REM echo. Killing and Restarting NMS.exe...
        REM TASKKILL.exe /F /FI "IMAGENAME eq NMS.exe" 1>NUL 2>NUL

        REM rem echo. Restarting NMS, please wait...
        REM START "" /B "%_bNMS_Binaries_FOLDER%NMS.exe" 1>NUL 2>NUL
        REM PING -n 6 127.0.0.1>nul
    REM ) else (
        REM echo. NMS.exe is still running...
        REM PING -n 3 127.0.0.1>nul
)

rem set "nms=%_bNMS_Binaries_FOLDER%NMS.exe"
if not [!NMSrunning!]==[opened] (
    echo.        ==^> Starting NMS to force update of GCMODSETTINGS.MXML...
    echo.             NOTE: Please accept request to run NMS if one appears
    cmd /c START "" /B "%_bNMS_Binaries_FOLDER%NMS.exe" %nulString%
    
    rem START "" /B "%_bNMS_Binaries_FOLDER%NMS.exe"
    rem %_bNMS_Binaries_FOLDER%NMS.exe 1>NUL 2>NUL
    rem %nms%
    set startingNMS=Y
    echo.      AFTER launching NMS.exe: %TIME%
)

pushd %_bNMS_SETTINGS_FOLDER%
if defined startingNMS (
    set "_bCount=0"
    :RETRY_NMS
    if !_bCount! GTR 1000 (
        echo.      xxxxx [WARNING] Problem Starting NMS.exe xxxxx
        if [!NMSrunning!]==[opened] (
            echo.      Killing NMS.exe: %TIME%
            TASKKILL.exe /F /FI "IMAGENAME eq NMS.exe" 1>NUL 2>NUL
        )
        goto :PROBLEM_NMS
    )
    SET /A "_bCount=_bCount+1"
    PING -n 1 127.0.0.1>nul
    FOR /f "usebackq delims=" %%I IN (`powershell.exe "& {Get-ItemPropertyValue -Path "GCMODSETTINGS.MXML" -Name LastWriteTime;}"`) do (
        rem echo. - new LastWriteTime: %%I
        if not [!modif_time!]==[%%I] (
            echo.        ==^> Done updating GCMODSETTINGS.MXML, killing NMS.exe...
            echo.      Killing app: %TIME%
            TASKKILL.exe /F /FI "IMAGENAME eq NMS.exe" 1>NUL 2>NUL
            goto :PROBLEM_NMS
        )
        PING -n 1 127.0.0.1>nul
    )
    goto :RETRY_NMS
)
:PROBLEM_NMS    
popd
echo.   Ended: %TIME%

rem pause
goto :eof

rem *****************************************************************************************
rem               --------------------- WE ARE DONE ---------------------
rem *****************************************************************************************

rem --------------------------------------------
rem subroutine section starts below

rem --------------------------------------------
