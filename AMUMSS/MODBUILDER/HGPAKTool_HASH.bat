@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
cd /d "%~dp0"

REM hgpaktool.exe -h
echo.

set /p _gNMS_versionId=<NMS_versionId.txt

if not [%*]==[] (
	set "out=..\TOOLS\NMSPE_Output\PAK_Content\Hash_v%_gNMS_versionId%.json"
	hgpaktool.exe --upper --hash "!out!" %*
	echo. AFTERhgpaktool.exe --upper --hash "!out!" %*
	echo.
) else (
	echo.
	echo. Please drag/drop pak folder on batch file
)

rem pause
