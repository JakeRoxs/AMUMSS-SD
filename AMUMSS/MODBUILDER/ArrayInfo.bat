@echo off
rem echo. we are in %CD%

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

Del /f /q "array_data.txt" 1>NUL 2>NUL

pushd ArrayInfo
call ArrayInfo.exe 1>nul 2>nul
popd

copy /Y /B "ArrayInfo\array_data.txt" "array_data.txt" >nul

echo.
echo.^>^>^> 'Array information' created

rem pause

REM [18:34]monkeyman192:  https://discord.com/channels/215514623384748034/1135580852424802305/1425250014388682763
REM : I would propose something maybe a bit stronger... If we're gonna go ahead and add meta info like this, why not just add all type info? Internally when HG producces files they have a type attribute as well. I don't have any examples of arrays to know if they have any extra meta on that, but at least for normal fields the type info just shows what the object is (so int, float, bool etc)
REM I'd also rename this attribute to array_size instead of just array.
REM And finally I'd make this off by default and add a command line flag like --typed to export mxml files in a "typed" veriety. This way the functionality may be beneficial to more than just AMUMSS 

REM [18:46]monkeyman192
REM : max string lengths is another one that messes people up some times
