--arg[1] == string:file EXT to check
--arg[2] == string: path to MODBUILDER

function Check_Log_file(logFile)
  local p = function(...) return end --to disable
  if LDebug then p = print end --active
  
  local sfile = H.LoadFileData(logFile)
  if #sfile == 0 then
    print(logFile.." is empty!")
  else
    if string.find(sfile,[[Extras\lua_x64\bin\lua.exe:]],1,true) then
      -- report problem
      print()
      print("==> Checking log.lua file...")
      print(H._zBRIGHTORANGE..[=[  [BUG] lua.exe generated an [ERROR]... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:]=]..H._zDEFAULT)
      print(H._zBRIGHTORANGE..[=[           https://discord.gg/22ZAU9H]=]..H._zDEFAULT)
      print()
      H.Report("")
      H.Report("",[=[    [BUG] lua.exe generated an [ERROR]... Please report log.lua AND this file to NMS Discord: "No Man's Sky Modding" channel, "amumss-lua" room:]=])
      H.Report("",[=[           https://discord.gg/22ZAU9H]=])
      H.Report_flush(false,THIS)
    end
  end
  
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER folder

LocalFolder = [[]]
IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile([[LoadHelpers.lua]]) end

H.pv(">>>     In Check_Log_file.lua")
THIS = "In Check_Log_file: "
LDebug = false

EXT = arg[1]

H.gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"")..[[\]] -- \ required because we are in AMUMSS folder

-- gPathToModScript = [[.\ModScript]]

logFile = H.gMASTER_FOLDER_PATH..[[log.lua]]
-- H.printf("logFile = [%s]",logFile)
if not H.IsFileExist(logFile) then
  logFile = H.gMASTER_FOLDER_PATH..[[log.txt]]
end

if H.IsFileExist(logFile) then
  Check_Log_file(logFile)
  -- print("    Done!")
  return
else
  print("    No log file to clean!")
end

print("Ended")
H.WFAK("end of Check_Log_file(), press key...")
-- H.LuaEndedOk(THIS)
