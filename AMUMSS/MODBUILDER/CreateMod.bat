@echo off
if defined _mVERBOSE (
	echo.^>^>^>     In CreateMod.bat
)
rem All defined variables in CreateMod.bat start with _c (except FOR loop first parameter)
rem so we can easily list them all like this on error, if needed: set _c

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem **********************  WE ARE IN MODBUILDER  *********************************
set "_cC="
if defined _mVERBOSE set "_cC=CreateMod.bat:"

set /p _cDateTime=<cleanedDateTime.txt

rem change to 1250 can trow problems (tested with lMonk)
REM CHCP 1250 1>nul 2>nul

REM Test if a MOD name exist
set /p _cMOD_FILENAME=<MOD_FILENAME.txt
REM echo. _cMOD_FILENAME = %_cMOD_FILENAME%

set /p _cMOD_AUTHOR=<MOD_AUTHOR.txt
REM echo. A: _cMOD_AUTHOR = %_cMOD_AUTHOR%
set "_cMOD_AUTHOR_FIRSTCHAR=%_cMOD_AUTHOR:~0,1%"
REM echo. _cMOD_AUTHOR_FIRSTCHAR = %_cMOD_AUTHOR_FIRSTCHAR%
if ["%_cMOD_AUTHOR_FIRSTCHAR%"]==["+"] (
	set "_cMOD_AUTHOR=.%_cMOD_AUTHOR:~1%"
) else (
	set "_cMOD_AUTHOR="
)
REM echo. B: _cMOD_AUTHOR = !_cMOD_AUTHOR!

if [] == [!_cMOD_FILENAME!] (
	echo.
	echo.%gcWARNING%^>^>^> [WARNING] No MOD filename. Not creating pak file for this script%_zDEFAULT%
	echo|set /p=".   [WARNING]     No MOD filename. Not creating pak file for this script">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	goto :ENDIT
) else (
	REM echo.^>^>^> Found the MOD filename
)

REM Test if a MOD BATCHNAME exist
set /p _cMOD_BATCHNAME=<MOD_BATCHNAME.txt

set "_BatchName=Y"
if [] == [!_cMOD_BATCHNAME!] (
	set "_BatchName=N"
)

set "_cName=CombinedMod_"
if defined _bPATCH (
	set "_cName=PatchMod"
	set "_cMOD_AUTHOR="
)


rem _bCOMBINE_MOD_TYPE:
rem on 0, treat as an Individual mod
rem on 1, treat as a generic combined mod with the current DATE-TIME suffix
rem on 2, treat as a distinct combined mod with a NUMERIC suffix
rem on 3, the name being like Mod1+Mod2+Mod3.pak, treat it as an Individual mod 

REM if %_bCOMBINE_MOD_TYPE% EQU 0 (
if [%-CombineModPak%]==[N] (
	set /p _cMOD_FILENAME=<MOD_FILENAME.txt
	goto :SKIP_COMBINE
)

if %_bCOMBINE_MOD_TYPE% EQU 1 ( set "_bCOMBINE_MOD_TYPE=3" )

if %_BatchName%==N (
	if %_bCOMBINE_MOD_TYPE% EQU 1 ( set "_cMOD_FILENAME=%_cName%_%_cDateTime%.pak")
	if %_bCOMBINE_MOD_TYPE% EQU 2 ( set "_cMOD_FILENAME=%_cName%.pak")
	if %_bCOMBINE_MOD_TYPE% EQU 3 ( set /p _cMOD_FILENAME=<Composite_MOD_FILENAME.txt )
) else (
	if %_bNumberScripts% GTR 1 (
		if defined _bPATCH (set "_cName=PatchMod")
		set _cMOD_FILENAME=%_cMOD_BATCHNAME%
	) else (
		if %_bCOMBINE_MOD_TYPE% EQU 1 ( set "_cMOD_FILENAME=%_cName%_%_cDateTime%.pak")
		if %_bCOMBINE_MOD_TYPE% EQU 2 ( set "_cMOD_FILENAME=%_cName%.pak")
		if %_bCOMBINE_MOD_TYPE% EQU 3 ( set /p _cMOD_FILENAME=<Composite_MOD_FILENAME.txt )
	)
)

:SKIP_COMBINE
if %_bCOMBINE_MOD_TYPE% GTR 0 (
	echo.>>"..\REPORT.lua"
)

rem set "_INFO=^[INFO] "
set "_INFO="

echo.>>"..\REPORT.lua"
echo|set /p="%_INFO%Starting final MBINCompiler and PAK phase...">>"..\REPORT.lua"
echo.>>"..\REPORT.lua"

rem **********************  WE ARE GOING INTO MOD  *********************************
cd MOD

REM echo. Paused before Compiling: check folder MOD content...
REM pause

rem ########################################################
rem ############### Compile to MBIN file ###################
rem ########################################################

echo.
echo.^>^>^> %_cC% Compiling EXML file(s) in MOD folder
echo.^>^>^>  MBINCompiler working...

set "_cEmpty= "
FOR /r %%G in (*.exml) do (
	echo.----- [INFO] %%G
	echo|..\MBINCompiler.exe -y -f "%%G" 1>NUL 2>NUL
	Call :LuaEndedOkREMOVE
	..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Compiling %%G"
	Call :LuaEndedOk
	)
)

rem now done in LoadAndExecuteModScript.lua
Call :LuaEndedOkREMOVE
..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Compiling"
Call :LuaEndedOk

rem check if we really have something to pak beside the script
SET "_cNumFiles=0"
FOR /r . %%G in (*.BIN,*.H,*.DDS,*.FNT,*.JSON,*.MBIN,*.MXML,*.PC,*.PNG,*.TTC,*.TTF,*.XML,*.WEM) do (
	SET /A "_cNumFiles=_cNumFiles+1"
)

if %_cNumFiles% EQU 0 (
	echo.
	echo.%_zBLACKonYELLOW% [NOTICE] Nothing to pak. Not creating pak file for this script %_zDEFAULT%
	echo|set /p=".   [NOTICE] Nothing to pak. Not creating pak file for this script">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"
	goto :ENDIT
)
rem END: check if we have really something to pak beside the script

set "_cDestination=..\..\CreatedMODS\BuildHistory\IncrementalBuilds"
set "_cFilename=%_cMOD_FILENAME:.pak=_%"

rem _bINDIVIDUAL_MODS=2 the name of the script
rem _bINDIVIDUAL_MODS=1 the name of the script + date-time

if %_bCOMBINE_MOD_TYPE% EQU 0 (
	if !_bINDIVIDUAL_MODS! EQU 1 (
		set "_cFilename=%_cFilename%%_cDateTime%.pak"
		REM echo.INDIVIDUAL MODNAME WITH DATE_TIME !_cFilename!
		
		set "_cMOD_FILENAME=%_cMOD_FILENAME:.pak=_%"
		REM echo.INDIVIDUAL MODNAME WITH DATE_TIME !_cMOD_FILENAME!
		set "_cMOD_FILENAME=!_cMOD_FILENAME!%_cDateTime%.pak"
		REM echo.INDIVIDUAL MODNAME WITH DATE_TIME !_cMOD_FILENAME!
	)
)

rem ****USER: seekker*****************************************************
rem ---->>>> set working directory for the max 10 paks loop
set "tempDel=%_cDestination%"

rem this will check if there are 10 pak already stored
If exist "%tempDel%\%_cFilename%(9).pak%_cMOD_AUTHOR%" goto :clearOld
goto :preLoop rem if less than 10 goes to preloop function

rem this function is intended to keep paks under 10 but still keep the last 5 paks
:clearOld
REM rem loop 0-4 in 1 step increments
REM FOR /L %%G IN (0,1,4) do del "%tempDel%\%_cFilename%(%%G).pak" 1>NUL 2>NUL

del "%tempDel%\%_cFilename%(0).pak%_cMOD_AUTHOR%" 1>NUL 2>NUL

rem get number of IncrementalBuilds to use
set /p __I=<IncrementalBuilds.txt
set /a "__I=%__I:~18%"
set /a "__I=__I-1"
rem echo.%__I%

rem loop 1-9 in 1 step increments -- renames paks 1-9 to 0-8
FOR /L %%A in (1,1,%__I%) do (
	SET /a "C=%%A"
    SET /a "B=%%A-1"
	rem "cmd.exe /c" is required to make some commands work when local bat launched from another /bat file /script or /program (in this case it could not find file without it)
	cmd.exe /c ren "%tempDel%\%_cFilename%(%%C%%).pak" "%_cFilename%(%%B%%).pak%_cMOD_AUTHOR%" 1>NUL 2>NUL
    REM call ECHO "%tempDel%\%_cFilename%(%%B%%).pak"
)
rem ****/seekker*****************************************************

:preLoop
rem find how many Builds we have done already for this mod
set "_ca=0"
:loop
if exist "%_cDestination%\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%" set /a "_ca+=1" && goto :loop

echo.----------------------------------------
echo.
echo.^>^>^> %_cC% Compressing MBIN (and possibly other) file(s) to PAK(s)

rem get length of current path
FOR /L %%G in (1 1 500) do if "!__cd__:~%%G,1!" neq "" set /a "_cLen=%%G+1"

rem ########################################################
rem ############### Compress to pak file ###################
rem ########################################################

setlocal DisableDelayedExpansion
(FOR /r . %%G in (*.BIN,*.H,*.DDS,*.FNT,*.JSON,*.lua,*.MBIN,*.MXML,*.PC,*.PNG,*.TTC,*.TTF,*.TXT,*.XML,*.WEM) do (
  @echo off
  set "_cAbsPath=%%G"
  setlocal EnableDelayedExpansion
  set "_cRelPath=!_cAbsPath:~%_cLen%!"
  echo(!_cRelPath!
  endlocal
)) > ..\"input.txt"

rem just in case...
setlocal EnableDelayedExpansion

REM rem ***********************
REM rem Contributed by mso53 on Discord
set "_CREATED_MOD_FOLDER=!CD!"
set "_STRIP_PATTERN=%_CREATED_MOD_FOLDER%"
rem remove C:\
set "_STRIP_PATTERN=%_STRIP_PATTERN:~3%"
rem change \ to /
set "_STRIP_PATTERN=%_STRIP_PATTERN:\=/%"
rem escape ( and )
set "_STRIP_PATTERN=%_STRIP_PATTERN:(=\(%"
set "_STRIP_PATTERN=%_STRIP_PATTERN:)=\)%"
rem escape +
set "_STRIP_PATTERN=%_STRIP_PATTERN:+=\+%"
rem escape $
set "_STRIP_PATTERN=%_STRIP_PATTERN:$=\$%"
rem escape ^
set "_STRIP_PATTERN=%_STRIP_PATTERN:^=\^%"
rem escape [ and  ]
set "_STRIP_PATTERN=%_STRIP_PATTERN:[=\[%"
set "_STRIP_PATTERN=%_STRIP_PATTERN:]=\]%"
rem escape {
set "_STRIP_PATTERN=%_STRIP_PATTERN:{=\{%"
REM rem ***********************

rem ########################################################
rem ############### Create Incremental Builds ##############
rem ########################################################

echo.
REM rem Contributed by mso53 on Discord
echo|..\psarc.exe create --overwrite --skip-missing-files --strip="%_STRIP_PATTERN%" --inputfile=..\input.txt --output="%_cDestination%\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%"
echo.

rem ########################################################
rem ############### Copy Mod to NMS Mod and root folder ####
rem ########################################################

rem if xcopy is asking "File or Directory?"  The "*" at the end makes it default to a file without asking

rem ******************************************************************************************************
rem Windows File Paths Limit is 260 characters including terminating null character
rem     (without editing Group Policy and it may not work on all version)
rem ******************************************************************************************************

rem on 0, treat as Individual mods
rem on 1, treat as a generic combined mod
rem on 2, treat as a distinct combined mod
rem on 3, a combined mod treated as an Individual mod, the name being like Mod1+Mod2+Mod3.pak

if %_bCOMBINE_MOD_TYPE% EQU 2 ( goto :COMBINEDDISTINCTMODS )
		
rem Individual or combined mods type 0, 1 or 3

rem removed /s
if [%_DEV_MODE%]==[D] xcopy /y /h /j "%_cDestination%\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%" "..\..\CreatedMODS\BuildHistory\%_cMOD_FILENAME%%_cMOD_AUTHOR%*" 1>NUL 2>NUL
rem removed /s
xcopy /y /h /j "%_cDestination%\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%" "..\..\CreatedMODS\%_cMOD_FILENAME%%_cMOD_AUTHOR%*"

rem if %_bCOMBINE_MOD_TYPE% EQU 0 (goto :NEXTSTEP)
if [%-CombineModPak%]==[N] (goto :NEXTSTEP )

rem case %_bCOMBINE_MOD_TYPE% EQU 1
rem case %_bCOMBINE_MOD_TYPE% EQU 3

REM Mod pak content required if generic combined
rem removed /s
if [%_DEV_MODE%]==[D] xcopy /y /h /j "..\COMBINED_CONTENT_LIST.txt" "..\..\CreatedMODS\BuildHistory\%_cMOD_FILENAME%%_cMOD_AUTHOR%_content.txt*" 1>NUL 2>NUL
rem removed /s
xcopy /y /h /j "..\COMBINED_CONTENT_LIST.txt" "..\..\CreatedMODS\%_cMOD_FILENAME%%_cMOD_AUTHOR%_content.txt*"

goto :NEXTSTEP

:COMBINEDDISTINCTMODS
rem distinct combined mods: 2
rem removed /s
if [%_DEV_MODE%]==[D] xcopy /y /h /j "%_cDestination%\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%" "..\..\CreatedMODS\BuildHistory\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%*" 1>NUL 2>NUL
rem removed /s
xcopy /y /h /j "%_cDestination%\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%" "..\..\CreatedMODS\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%*"

REM Mod pak content required if distinct combined
rem removed /s
if [%_DEV_MODE%]==[D] xcopy /y /h /j "..\COMBINED_CONTENT_LIST.txt" "..\..\CreatedMODS\BuildHistory\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%_content.txt*" 1>NUL 2>NUL
rem removed /s
xcopy /y /h /j "..\COMBINED_CONTENT_LIST.txt" "..\..\CreatedMODS\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%_content.txt*"

rem all above code passes thru here
:NEXTSTEP

set /p _cNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt
set "_cNMS_PCBANKS_FOLDER=%_cNMS_FOLDER%\GAMEDATA\PCBANKS\"
set "_cNMS_MODS_FOLDER=%_cNMS_PCBANKS_FOLDER%MODS\"

rem in case it does not exist
mkdir "%_cNMS_MODS_FOLDER%" 2>NUL

rem enable MODS in NMS
del /F /Q "%_cNMS_PCBANKS_FOLDER%DISABLEMODS.TXT" 1>NUL 2>NUL

if %_bCOPYtoNMS%==ALL goto :COPYALLtoNMS
if %_bCOPYtoNMS%==SOME goto :COPYSOMEtoNMS

rem case where %_bCOPYtoNMS%==NONE
goto :ENDIT

:COPYSOMEtoNMS
echo.
REM CHOICE /c:yn /m "%_zBRIGHTRED%??? Would you like to copy the created pak to your game folder and delete [DISABLEMODS.TXT] %_zDEFAULT%"
REM if %ERRORLEVEL% EQU 2 goto :ENDIT
REM CALL :MYCHOICE
CALL ..\MyChoice.bat
if defined _cChoice goto :ENDIT

echo.
echo.^>^>^> Copying this PAK to NMS MOD folder...
echo|set /p="%_INFO%Copied this PAK to NMS MOD folder">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"

if %_bCOMBINE_MOD_TYPE% EQU 2 ( goto :CopyCOMBINEDDISTINCTMODS )

rem removed /s
xcopy /y /h /j "..\..\CreatedMODS\%_cMOD_FILENAME%%_cMOD_AUTHOR%" "%_cNMS_MODS_FOLDER%*" 	
rem removed /s
xcopy /y /h /j "..\..\CreatedMODS\%_cMOD_FILENAME%%_cMOD_AUTHOR%_content.txt" "%_cNMS_MODS_FOLDER%*" 	

goto :ENDIT

:CopyCOMBINEDDISTINCTMODS
rem removed /s
xcopy /y /h /j "..\..\CreatedMODS\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%" "%_cNMS_MODS_FOLDER%*" 	
rem removed /s
xcopy /y /h /j "..\..\CreatedMODS\%_cFilename%(%_ca%).pak%_cMOD_AUTHOR%_content.txt" "%_cNMS_MODS_FOLDER%*" 	

goto :ENDIT

:COPYALLtoNMS
rem removed /s
xcopy /y /h /j "..\..\CreatedMODS\*.*" "%_cNMS_MODS_FOLDER%*" 	

if %_bNumberPAKs% GTR 0 (
	rem xcopy /s /y /h /j "..\..\ModScript\*.pak.*" "%_cNMS_MODS_FOLDER%*"
	rem removed /s (no folder or sub-folder)
	xcopy /y /h /j "..\..\ModScript\*.pak.*" "%_cNMS_MODS_FOLDER%*"
)

rem if %_bCOMBINE_MOD_TYPE% EQU 0 (
if [%-CombineModPak%]==[N] (
	echo.
	echo.%_zBRIGHTGREEN%^>^>^> Copying this PAK to NMS MOD folder...%_zDEFAULT%
)

echo.-----------------------------------------------------------
:ENDIT	
set "_cChoice="

rem ****************************  WE ARE GOING BACK TO MODBUILDER  ****************************
cd ..
@echo off

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
REM :MYCHOICE
	REM CHOICE /c:yn /m "%_zBRIGHTRED%??? Would you like to copy the created pak to your game folder and delete [DISABLEMODS.TXT] %_zDEFAULT%"
	REM if %ERRORLEVEL% EQU 2 set _cChoice="N"
	REM EXIT /B

:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.          From CreateMod.bat>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an [ERROR]... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------

EXIT
