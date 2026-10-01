-- ****************************************************
-- main
-- ****************************************************
if H == nil then dofile("LoadHelpers.lua") end

if os.getenv("_gVERBOSE") == "Y" then
  print("   @@@ Detected _gVERBOSE=Y @@@")
  H.gVerbose = true
end

-- H.pv("In CreateMapFileTreeStarter.lua")

if not H.IsFileExist("MapFileTreeRequested.txt") then
  -- H.pv("MapFileTreeRequested.txt does not exist!")
  H.WriteToFile("","MapFileTreeRequested.txt")

	-- tasklist /FI "IMAGENAME eq luaM.exe" /V /Fo CSV 2>NUL|"%__AppDir__%find.exe" /I "luaM.exe">NUL&&(set "running=opened")||set "running=closed")
	-- if [!running!]==[opened] (
		-- echo.   ^>^>^> luaM.exe is already running
	-- ) else (
		-- echo. Starting luaM.exe...
	-- )

  print("=== Starting MapFileTree thread ===")
  -- print("ZZZZZZZZZZZ ".."Starting 2nd thread cmd...")
  -- print("ZZZZZZZZZZZ "..lfs.currentdir())
	
  -- io.popen([[START "CreateMapFileTree_luaM" /MIN ]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]])
  
  -- set filepath = os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]]
  -- local command = [[CreateObject("WScript.Shell").Run """%windir%\System32\cmd.exe"" /c start ""CreateMapFileTree_luaM"" ""%filepath%""", 0]]
  -- local status,exitcode,exitnumber = os.execute(command)
  
  -- flashes a window
  -- local command = [[TEST_MAP_STARTER.bat]]

  -- works
  -- local command = [[cmd /c start "" /min TEST_MAP_STARTER.bat]]
  
  -- works
  -- local command = [[start "" /min cmd.exe /c wscript.exe "MapFileTreeStarter.vbs"]]

  local command = [[start "" /min wscript.exe "MapFileTreeStarter.vbs"]]
  local status,exitcode,exitnumber = os.execute(command)
  
  -- current version
  -- -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
  -- local status,exitcode,exitnumber = os.execute([[START "CreateMapFileTree_luaM" /MIN ]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]])
  -- -- H.printf("%s %s %d",tostring(status),tostring(exitcode),exitnumber)
  
  
    -- local cmd= [[cmd /c ]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]]
    -- -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
    -- local command = [[START "CreateMapFileTree_luaM" /MIN "]]..cmd..[["]]
  -- local status,exitcode,exitnumber = os.execute(command)
  
  print("    >>> Running...")
  -- -- works DETACHED, but show a cmd window by intermittance
  -- -- local cmd = [[runThisJob.exe "cmd.exe /c .\]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]]..[[ "]]
  -- -- local cmd = [[runThisJob.exe "START /B 'CreateMapFileTree_luaM' /MIN .\]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]]..[[ "]] -- NOT WORKING
  -- -- local cmd = [[runThisJob.exe ".\]]..os.getenv("_mLUAM")..[[ CreateMapFileTree.lua]]..[[ "]] -- FLASHING console windows
  
  -- -- local cmd = [[powershell]]
  -- -- print("ZZZZZZZZZZZ "..cmd)
  -- -- os.execute(cmd)

  --to debug, see file MapFileTreeRunner.lua
else
  -- H.pv("MapFileTreeRequested.txt exist already!")
  
end
-- H.WFAK("CreateMapFileTreeStarter END...")
-- print("ZZZZZZZZZZZ ".."Exit from CreateMapFileTreeStarter.lua")
