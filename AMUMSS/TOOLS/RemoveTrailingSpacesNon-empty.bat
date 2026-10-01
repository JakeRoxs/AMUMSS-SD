@echo off
REM @echo on

title Remove trailing spaces plus...

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

%_mLUA% "RemoveTrailingSpacesNon-empty.lua" -v1 %*
goto :ENDING

:USAGE
echo.
echo.   USAGE: Drag and drop files on batch file
echo.
echo.   RESULT can be found in CLEANED folder 
echo.
echo.      When using the shortcut 'RemoveTrailingSpaces.bat'
echo.        You can add/remove options from Properties\Target:
echo.          -noindent (empty lines are not indented)
echo.          -spaceIndentSize X (where X = how many spaces to indent, defaults to 4)
echo.          -TabToSpaces (convert leading Tabs to Spaces, disabled if -spaceIndentSize is missing)
goto :END

:ENDING
echo.
echo.   DONE PROCESSING

:END
echo.
pause
exit
