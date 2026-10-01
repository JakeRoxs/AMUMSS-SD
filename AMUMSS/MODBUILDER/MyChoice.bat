CHOICE /c:yn /m "%_zBRIGHTRED%??? Would you like to copy the created MOD to your game folder %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 set _cChoice="N"
EXIT /B
