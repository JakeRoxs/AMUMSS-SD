@echo off
REM @echo on

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

echo. This v1.3 =================  ======================  ========================== ===================================

echo. %CD%

rem remark to allow running in any folder
cd ..\MODBUILDER\MBINCompilerDownloader
echo. %CD%

echo. Testing write access...
echo TEST_WRITE_ACCESS>TEST_WRITE_ACCESS.txt
if not exist "TEST_WRITE_ACCESS.txt" (
    echo. ==^> WARNING: Could not write file
) else (
    echo.    ==^> write access is OK
    del /f /q TEST_WRITE_ACCESS.txt 1>NUL 2>NUL
)

set "_wincurl=external"
echo. Using %_wincurl% curl
curl.exe -s -H "Accept: application/vnd.github.raw+json" "https://api.github.com/repos/monkeyman192/MBINCompiler/releases" -o curltmp.txt

rem Read first lines
(for /L %%i in (1,1,1) do set /P "line[%%i]=") < curltmp.txt

rem Process them
for /L %%i in (1,1,1) do (
   echo !line[%%i]!
)
del /f /q curltmp.txt 1>NUL 2>NUL

set "_curlpath="
if exist %SYSTEMROOT%\system32\curl.exe (
	set "_curlpath=%SYSTEMROOT%\system32\"
	set "_wincurl=internal"
)

echo.
echo. Using %_wincurl% curl =================  ======================  ========================== ===================================
%_curlpath%curl.exe -s -H "Accept: application/vnd.github.raw+json" "https://api.github.com/repos/monkeyman192/MBINCompiler/releases" -o curltmp.txt

rem Read first lines
(for /L %%i in (1,1,1) do set /P "line[%%i]=") < curltmp.txt

rem Process them
for /L %%i in (1,1,1) do (
   echo !line[%%i]!
)
del /f /q curltmp.txt 1>NUL 2>NUL

echo.
echo.  PLEASE COPY/PASTE the content in a file or do a screenshot and post
pause
