@echo off
REM echo.^>^>^>      In ExtractMODfromPAK.bat

rem All defined variables in ExtractMODfromPAK.bat start with _e (except FOR loop first parameter)
rem so we can easily list them all like this on error, if needed: set _e

REM SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

REM set "_eE=E:"
REM if defined _mVERBOSE set "_eE=ExtractMODfromPAK.bat:"

REM set "_INFO=^[INFO] "
REM set "_INFO="

REM echo.^>^>^> ExtractMODfromPAK: Starting directory
REM echo.!CD!

REM rd /S /Q "!CD!\_TEMP2" 1>NUL 2>NUL

REM REM echo.
REM if not exist "!CD!\_TEMP2" (
	REM mkdir "!CD!\_TEMP2\"
	REM xcopy /y /h "..\MODBUILDER\psarc.exe" "!CD!\_TEMP2\" 1>NUL 2>NUL
REM )

REM xcopy /y /h "%_bPaknamePATH%" "!CD!\_TEMP2\" 1>NUL 2>NUL

REM REM echo.
REM REM echo.^>^>^> ExtractMODfromPAK: Changing to directory _TEMP2
REM cd _TEMP2
REM echo.^>^>^> Changed to !CD!



REM ******   NOW IN ModScript   ********
xcopy /y /h "..\MODBUILDER\psarc.exe" "..\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" 1>NUL 2>NUL

echo.
echo.%_zBRIGHTGREEN%^>^>^> Unpacking, %_zDEFAULT%please wait...
echo|set /p="%_INFO%  Unpacking...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"

pushd %CD%

cd "..\TOOLS\UNPACKED_DECOMPILED_PAKs\!_bPAKname!"
REM echo.^>^>^> Changed to !CD!

FOR /r %%H in (*.pak.*) do (
	rem psarc.exe extract "%%H" --to="..\EXTRACTED_PAK" -y 1>NUL 2>NUL
	psarc.exe extract "%%H" --to="EXTRACTED_PAK" -y 1>NUL 2>NUL
)

Del /f /q "psarc.exe" 1>NUL 2>NUL

REM echo.
REM echo.^>^>^> Extracted %_bNumberFiles% PAK file(s)
rem cd ..
popd
REM echo.^>^>^> Back in !CD!
REM ******   NOW IN ModScript   ********

REM echo.
REM echo.%_zBRIGHTGREEN%^>^>^> Saving EXTRACTED_PAK to TOOLS\UNPACKED_DECOMPILED_PAKs folder, please wait...%_zDEFAULT%

REM rem doing it in two steps so we can use the pak info in ModScript with a .lua
REM rem when one exist (inside the pak or from the user)
REM ROBOCOPY /e /j "EXTRACTED_PAK" "..\TOOLS\UNPACKED_DECOMPILED_PAKs\%_bPAKname%\EXTRACTED_PAK" 1>NUL 2>NUL

REM Del /f /q /s "_TEMP2\*.*" 1>NUL 2>NUL
REM :RETRY
REM if exist "_TEMP2" (
	REM rd /s /q "_TEMP2" 2>NUL
	REM goto :RETRY
REM )


