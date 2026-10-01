function CheckUserScriptSyntax(UserScriptName)
  local LineTable = H.ParseTextFileIntoTable(UserScriptName)
  local TempTable = {}
  
  for i=1,#LineTable do
    local text = LineTable[i]
    if string.find(text,[[.lua ]],1,true) then
      TempTable[#TempTable+1] = string.sub(text,1,string.find(text,[[ (]],1,true)-1)
    end
  end
  
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER

LocalFolder = ""
if H == nil then dofile(LocalFolder.."LoadHelpers.lua") end
H.pv(">>>     In CheckUserScript.lua")
THIS = "In CheckUserScript: "

-- H.gfilePATH = "..\\" --for Report()

THIS = "In CheckUserScript: " --Check for THIS in code before changing this string

--not used
--gMASTER_FOLDER_PATH = H.LoadFileData(LocalFolder.."MASTER_FOLDER_PATH.txt")
--gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"")

local UserScriptName = H.LoadFileData("CurrentModScript.txt")

CheckUserScriptSyntax(UserScriptName)
H.LuaEndedOk(THIS)

