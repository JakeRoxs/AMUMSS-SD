@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
cd /d "%~dp0"

pip install zstandard
pause

hgpaktool.exe -h
echo.

set /p _bNMS_FOLDER=<..\CONFIG\NMS_FOLDER.txt 1>NUL 2>NUL
set "PCBANKS_path=%_bNMS_FOLDER%\GAMEDATA\PCBANKS"
echo. PCBANKS_path = %PCBANKS_path%

REM del "PAK_FILE_CONTENT.txt"

REM echo. List file content
REM hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" %*
REM echo. AFTER hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" %*
REM echo.
REM pause

    echo. TEST OLD PSARC modder pak, should report BAD pak type
    set "command=hgpaktool.exe --upper ".\HGPAK\_______KibblesNBytes_OLD_TEST.pak""
    echo. BEFORE %command%
	%command%
    echo.
    pause

    echo. TEST OLD NMS PSARC pak, should report BAD pak type
    set "command=hgpaktool.exe --upper -L -p -O "TEST_OLD_NMS_PAK.txt" "%PCBANKS_path%""
    echo. BEFORE %command%
	%command%
    echo.
    pause

    echo. Result in "filenames.json"
    echo. BEFORE hgpaktool.exe --upper -L "%PCBANKS_path%\NMSARC.globals.pak" "%PCBANKS_path%\NMSARC.TexPlanetSNOW.pak"
    hgpaktool.exe --upper -L "%PCBANKS_path%\NMSARC.globals.pak" "%PCBANKS_path%\NMSARC.TexPlanetSNOW.pak"
    echo.
    pause

    echo. OUTPUT goes to EXTRACTED
    echo. BEFORE HGPAKTool.exe -U --upper -f "*_ENGLISH.*" "%PCBANKS_path%"
    HGPAKTool.exe -U --upper -f "*_ENGLISH.*" "%PCBANKS_path%"
    echo.
    pause

    echo. OUTPUT goes to EXTRACTED
    echo. BEFORE HGPAKTool.exe -U --upper "%PCBANKS_path%\NMSARC.audioBNK.pak"
    HGPAKTool.exe -U --upper "%PCBANKS_path%\NMSARC.audioBNK.pak"
    echo.
    pause

    echo. OUTPUT goes to EXTRACTED
    echo. BEFORE HGPAKTool.exe -U --upper "%PCBANKS_path%\NMSARC.TexBiomesAlpine.pak"
    HGPAKTool.exe -U --upper "%PCBANKS_path%\NMSARC.TexBiomesAlpine.pak"
    echo.
    pause

REM if not [%*]==[] (
	REM hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" %*
	REM echo. AFTER hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" %*
	REM echo.
	REM pause
REM )

	REM echo. BEFORE hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" "%PCBANKS_path%\NMSARC.Precache.pak"
	REM hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" "%PCBANKS_path%\NMSARC.Precache.pak"
	REM echo.
	REM pause

REM echo. NEXT COMMAND WILL UNPACK EVERYTHING:  could be a bit long...
REM pause
	REM echo. BEFORE hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" "%PCBANKS_path%"
	REM hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" "%PCBANKS_path%"
	REM echo.

del "PAK_FILE_CONTENT.txt"

REM set "out=..\TOOLS\NMSPE_Output\PAK_Content\Hash_v%_gNMS_versionId%.json"

    REM hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.MetadataEtc.pak"
REM echo. AFTER hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.MetadataEtc.pak"
REM echo.

    echo. BEFORE hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.globals.pak"
    hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.globals.pak"
    echo.
    pause

    echo. BEFORE hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.audioBNK.pak"
    hgpaktool.exe --upper -L -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.audioBNK.pak"
    echo.
    pause

    REM hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" -f "LANGUAGE/NMS_LOC6_ENGLISH.MBIN" "%PCBANKS_path%\NMSARC.MetadataEtc.pak"
	REM echo. AFTER hgpaktool.exe -U --upper -v -O ".\_TEMP\EXTRACTED" -f "LANGUAGE/NMS_LOC6_ENGLISH.MBIN" "%PCBANKS_path%\NMSARC.MetadataEtc.pak"
	REM echo.
REM pause

    REM hgpaktool.exe -L --upper -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.misc.pak"
REM echo. AFTER hgpaktool.exe -L --upper -p -O "PAK_FILE_CONTENT.txt" "%PCBANKS_path%\NMSARC.misc.pak"
REM echo.
REM pause

    echo. -A supresses the message "Unpacked x files from x .pak's in x sec"
    echo. BEFORE hgpaktool.exe -U --upper -A --nmspeverbose -O ".\_TEMP\EXTRACTED" "filenames.json"
    hgpaktool.exe -U --upper -A -O ".\_TEMP\EXTRACTED" "filenames.json"
    echo.
    pause

    REM set "command=hgpaktool.exe -U --upper -O ".\_TEMP\EXTRACTED" "ExtractFromNMSPaksNMSPE.json""
    REM echo. BEFORE %command%
	REM %command%
    REM echo.
    REM pause

    echo. --nmspeverbose adds the message "Unpacking ==> pakname"
    set "command=hgpaktool.exe -U --nmspeverbose --upper -O ".\_TEMP\EXTRACTED" "ExtractFromNMSPaks.json""
    echo. BEFORE %command%
	%command%
    echo.
    pause

    echo. --nmspeverbose adds the message "Unpacking ==> pakname"
    set "command=hgpaktool.exe -U --nmspeverbose --upper -O "G:\AMUMSS\TOOLS\NMSPE_Output\DEFAULT_UNPACKFOLDER" "Explorer_HGPAK.json"
    echo. BEFORE %command%
	%command%
    echo.
    pause
