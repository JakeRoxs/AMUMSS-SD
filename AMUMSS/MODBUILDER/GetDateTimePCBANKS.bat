@echo off
REM if exist DEBUG.txt (
	REM if not defined _min_subprocess ((cmd /k set _min_subprocess=y ^& %0 %*) & exit )
	REM echo ################ IN DEBUG MODE ################
	REM echo.
REM )
REM SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

REM WE ARE in MODBUILDER
set "_pPCBanks_LISTdateTime=PCBanks_listDateTime.txt"
set "_pMODBUILDERDirectory=!CD!"

rem set /p _bMASTER_FOLDER_PATH=<MASTER_FOLDER_PATH.txt

set /p _gNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt
set "_gNMS_PCBANKS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\PCBANKS"

del /q "%_pPCBanks_LISTdateTime%" 1>NUL 2>NUL

REM rem if it still exist, should not exist if AMUMSS was able to refresh the scripts
REM if exist "RefreshScripts.txt" (
	REM del /q "RefreshScripts.txt" 1>NUL 2>NUL
REM )

pushd "%_gNMS_PCBANKS_FOLDER%"  1>NUL 2>NUL
REM echo.^>^>^> Changed to !CD!

copy "%_pMODBUILDERDirectory%\PAK_LIST_CREATED.txt" 1>NUL 2>NUL
dir /O:-D /T:W /A:-D /B>>"%_pMODBUILDERDirectory%\%_pPCBanks_LISTdateTime%"
del /q "PAK_LIST_CREATED.txt" 1>NUL 2>NUL
del /q "NMS_VERSION_CREATED.txt" 1>NUL 2>NUL

popd
REM BACK in MODBUILDER

REM get first filename
Set /P _gFILE=<PCBanks_listDateTime.txt

if "%_gFILE%" == "PAK_LIST_CREATED.txt" set "_gNoNeedToCreatePAKlist=y"

REM echo.
if defined _gNoNeedToCreatePAKlist (
	REM echo.^>^>^> NMS PAK file list is up-to-date, no need to re-create the list
	goto :CONTINUE
)

echo.^>^>^> The NMS PAK file list must be re-created...
del /q "pak_list.txt" 1>NUL 2>NUL
del /q "PAK_LIST_CREATED.txt" 1>NUL 2>NUL

rem tell AMUMSS to refresh all scripts that need to be refreshed
if [%-CreateUsefulUtilityScripts%]==[Y] (
    echo.> "RefreshScripts.txt"
    if exist "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" (
        del /q "ModScript\ModHelperScripts\Dictionary_OUTDATED.lua" 1>NUL 2>NUL
    )
)

:CONTINUE
REM echo.^>^>^> Changed to !CD!

:DONE
REM MUST GO BACK TO MASTER_FOLDER_PATH
REM cd ..
