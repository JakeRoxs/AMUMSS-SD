--arg[1] == string:file EXT to check
--arg[2] == string: path to MODBUILDER

--Only files with EXT extension in ModScript and sub-directory that do not contain DONOTUSE_name
function Log_file_cleaner(logFile)
  local p = function(...) return end --to disable
  if LDebug then p = print end --active
  
  local file = H.ParseTextFileIntoTable(logFile)
  if #file == 0 then
    print(logFile.." is empty!")
  end
  
  -- print("Trying to delete "..logFile)
  -- repeat
    -- --H.DeleteFile(logFile)
    -- os.remove(logFile)
  -- until not H.IsFileExist(logFile)
  -- print(logFile.." deleted")
  
  local newFile = {}
  local skipSection = false
  
  for i=1,#file do
    local s = file[i]
    if H.trim(s) ~= "" then
      if s:find("=== DEEPDUMP") or s:find("MMM ShowLocals") then
        skipSection = true
      end
      if s:find("=== END: DEEPDUMP") or s:find("=== END: ShowLocals") then
        skipSection = false
      end
      if skipSection then
        newFile[#newFile+1] = s
      else
        if H.trim(s):sub(1,3) ~= [[[F]] then
          s = s:gsub([[.-m]],"")
          newFile[#newFile+1] = s
        end
      end
    elseif i > 1 and H.trim(file[i-1]) ~= "" then
      --if previous is not also empty, keep this empty line
      newFile[#newFile+1] = s
    end
    
    if string.find(s,[[]],1,true) then
      -- print("BEL at "..i.." with "..#newFile.." lines")
      newFile[#newFile] = ""
      break
    end
  end

  local newFile = H.ConvertLineTableToText(newFile)
  H.WriteToFile(newFile,logFile)
  
  -- copy log.lua to TOOLS\REPORTS_BACKUP
  -- date format for REPORTS
  local now = os.date("%Y%m%d-%H%M%S")

  local cleanedNowREPORT = now:gsub([[/]],[[]]):gsub([[\]],[[]]):gsub([[:]],[[]]):gsub([[*]],[[]]):gsub([[?]],[[]]):gsub([["]],[[]]):gsub([[<]],[[]]):gsub([[>]],[[]]):gsub([[|]],[[]])
  H.CopyFile(logFile,[[..\TOOLS\REPORTS_BACKUP\_____log_]]..cleanedNowREPORT..[[.lua*]],nil,true)
  -- END: copy REPORT.lua to TOOLS\REPORTS_BACKUP
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER folder

LocalFolder = [[]]
if H == nil then dofile([[LoadHelpers.lua]]) end

H.pv(">>>     In MXMLtoEXML_Log_file_cleaner.lua")
THIS = "In MXMLtoEXML_Log_file_cleaner: "
LDebug = false

EXT = arg[1]

H.gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"")..[[\]] -- \ required because we are in AMUMSS folder

-- gPathToModScript = [[.\ModScript]]

logFile = [[..\TOOLS\MXMLtoEXML_log.lua]]
-- H.printf("logFile = [%s]",logFile)

if H.IsFileExist(logFile) then
  print("==> Cleaning MXMLtoEXML_log.lua file...")
  Log_file_cleaner(logFile)
  -- print("    Done!")
  return
else
  print("    No MXMLtoEXML_log file to clean!")
end

print("Ended")
H.WFAK("end of MXMLtoEXML_Log_file_cleaner(), press key...")
-- H.LuaEndedOk(THIS)
