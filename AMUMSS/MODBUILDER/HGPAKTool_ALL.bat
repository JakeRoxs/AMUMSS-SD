@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
cd /d "%~dp0"

if [%1]==[] (
	echo. INSTRUCTIONS:
	echo.   - Create or use an existing folder to receive the UNPACKED files
	echo.   - Drag and Drop this folder onto this batch file to UNPACK all NMS PCBANKS files
	echo.
	echo. ==^> batch will close now
	pause
	exit
) else (
    echo. This UNPACK folder will be used: %1%
)
echo.
REM pause

REM Set path to your UNPACK Folder
set "UNPACKED_NMS_PATH=%1"

rem DO NOT CHANGE BELOW
set /p _gNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt
set "_gNMS_PCBANKS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\PCBANKS"

hgpaktool.exe -U --upper -v -O "%UNPACKED_NMS_PATH%" "%_gNMS_PCBANKS_FOLDER%"

REM pause
