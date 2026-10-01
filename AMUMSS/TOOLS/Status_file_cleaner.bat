@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

set "_mLUA=Extras\lua_x64\bin\lua.exe"
cd ..\MODBUILDER 1>NUL 2>NUL

%_mLUA% Status_file_cleaner.lua

REM pause
exit
