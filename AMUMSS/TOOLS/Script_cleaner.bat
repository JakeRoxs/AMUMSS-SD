@echo off
REM @echo on

title Clean scripts...

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

%_mLUA% "Script_cleaner.lua" -v1 %*
goto :ENDING

:USAGE
echo.
echo.   USAGE: Drag and drop files on batch file
echo.
echo.   RESULT can be found in CLEANED folder 
echo.
goto :END

:ENDING
echo.
echo.   DONE PROCESSING

:END
echo.
pause
exit
