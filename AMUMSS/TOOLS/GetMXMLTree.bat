@echo off
REM @echo on

title GetMXMLTree

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

%_mLUA% "GetMXMLTree.lua" -v1 %*
goto :ENDING

:USAGE
echo.
echo.   USAGE: Drag and drop MXML files on batch file
goto :END

:ENDING
echo.
echo.   DONE GETTING MXML TREE INFO

:END
echo.
pause
