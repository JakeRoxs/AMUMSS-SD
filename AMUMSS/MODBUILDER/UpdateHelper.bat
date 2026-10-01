@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

REM echo. %CD%

REM allow all file types, except .lua scripts and .MBIN
xcopy /f /s /y /h /e /i /j /c "MODBUILDER\MOD\*.*" "TOOLS\MODDER_Helper\MODDED\" /EXCLUDE:MODBUILDER\xcopy_exclude.txt 1>NUL 2>NUL

REM echo|set /p=".MXML">>"MODBUILDER\exclude.txt"
for /R .\TOOLS\MODDER_Helper\MODDED\ %%G in (*.MXML) do (
	REM echo. - %%G
	set "_org=%%G"
	REM echo. - !_org!
	REM echo.
	set "_tmpDest=!_org:MODDED=ORG_MXML!"
	REM echo. - _tmpDest = [!_tmpDest!]
	set "_tmpSrc=!_org:TOOLS\MODDER_Helper\MODDED=MODBUILDER\_TEMP\DECOMPILED!"
	REM echo. - _tmpSrc = [!_tmpSrc!]
	REM allow all file types
	xcopy /s /y /h /i /j /c "!_tmpSrc!" "!_tmpDest!*" 1>NUL 2>NUL

	REM REM echo.
	REM set _tmpDest=!_org:MODDED=EXTRACTED!
	REM set _tmpDest=!_tmpDest:.MXML=.MBIN!
	REM set _tmp=!_tmpDest:.GEOMETRY.=!
	REM if NOT [!_tmp!]==[!_tmpDest!] (set _tmpDest=!_tmpDest:.MBIN=.MBIN.PC!)
	REM REM echo. - _tmpDest = [!_tmpDest!]
	REM set _tmpSrc=!_org:TOOLS\MXML_Helper\MODDED=MODBUILDER\_TEMP\EXTRACTED!
	REM set _tmpSrc=!_tmpSrc:.MXML=.MBIN!
	REM REM echo. - _tmpSrc = [!_tmpSrc!]
	REM REM exclude the .MXML files
	REM xcopy /s /y /h /i /j /c "!_tmpSrc!" "!_tmpDest!*" 1>NUL 2>NUL

	REM echo. --------------
)

REM echo. END
REM pause
exit
