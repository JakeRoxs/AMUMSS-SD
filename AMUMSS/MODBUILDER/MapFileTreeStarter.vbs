OPTION EXPLICIT

' Dim console

' console = False
' if instr(ucase(WScript.FullName), "CSCRIPT") > 0 then
    ' console = true
' end if

' If console then
  ' ' Execute console specific commands
' else
  ' ' Execute Windows UI specific commands
' end if

' Sub Pause()
    ' cScript.Echo ("Press Enter to continue")
    ' z = cScript.StdIn.ReadLine
' End Sub

' wscript.Sleep 5000

' CreateObject("WScript.Shell").Run " ""%windir%\System32\cmd.exe"" /c start ""CreateMapFileTree_luaM"" "".\Extras\lua_x64\bin\luaM.exe  "CreateMapFileTree.lua" "" ", 0
dim objShell, command, intReturn

set objShell = CreateObject("WScript.Shell")

' How to execute this?
' .\Extras\lua_x64\bin\luaM.exe  "CreateMapFileTree.lua"

command = "%windir%\System32\cmd.exe /c Run_MAP_Starter.bat" 

intReturn = objShell.Run( command, 7 )
if intReturn <> 0 then
	wscript.Echo "VBS: Error running Program"
end if

' wscript.Sleep 5000
' Pause
