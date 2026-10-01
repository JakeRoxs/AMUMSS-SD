@echo off
REM @echo on

title MXML_NameHash_updater

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
cd /d "%~dp0"

set "_mLUA=Extras\lua_x64\bin\lua.exe"

if [%1]==[] goto :USAGE

REM -- OPTION verboseLevel:
REM --  -v0 == just essential info
REM --  -v1 == more info
REM --  -v2 == all DEBUG info

cd ..\MODBUILDER
%_mLUA% -e print(_VERSION)
echo.

%_mLUA% "MXML_NameHash_updater.lua" -v2 %*
goto :ENDING

:USAGE
echo.
echo.   USAGE: Drag and drop .MXML file^(s) and/or folder^(s) on batch file
goto :END

:ENDING
echo.
echo.   DONE processing ALL files

:END
echo.
pause
