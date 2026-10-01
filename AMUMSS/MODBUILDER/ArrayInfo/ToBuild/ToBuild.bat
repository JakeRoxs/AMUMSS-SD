@echo off

dotnet publish --no-self-contained -c Release -f net8.0 -r win-x64 /nowarn:cs0618 /nowarn:cs0169 /nowarn:cs0414

copy /Y /B ".\Build\Release\net8.0\win-x64\ArrayInfo.exe" "..\ArrayInfo.exe" >nul
copy /Y /B ".\Build\Release\net8.0\win-x64\ArrayInfo.dll" "..\ArrayInfo.dll" >nul
copy /Y /B ".\Build\Release\net8.0\win-x64\ArrayInfo.runtimeconfig.json" "..\ArrayInfo.runtimeconfig.json" >nul

pause
