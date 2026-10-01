--arg[1] == string:file EXT to check
--arg[2] == string: path to MODBUILDER
--arg[3] == string: to indicate to create a composite name for the pak
--arg[4] == string: report pathTooLongList
--arg[5] == string: Caller location

-- LDebug = true

--Only files with EXT extension in ModScript and sub-directory that do not contain DONOTUSE_name
function SearchModScriptForFileExt(EXT)
  -- local p = function(...) return end --to disable
  -- if LDebug then p = print end --active
  
  -- p("FROM SearchModScriptForFileExt")
  H.GetModScriptValidContent(gPathToModScript)
  
  local count = 0
  for i=1,#H.gScriptList do
    if not H.gScriptList[i][3] and H.gScriptList[i][2] == "" then
      count = count + 1
    end
  end
  
  -- local ModScriptEXTDirList = {}
  -- ModScriptEXTDirList = H.GetFilesWithExt(EXT)
  -- p(" YYYYY #ModScriptEXTDirList = ["..#ModScriptEXTDirList.."]")
  
  --return #ModScriptEXTDirList
  return count -- #H.gScriptList
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER folder

LocalFolder = [[]]
if H == nil then dofile([[LoadHelpers.lua]]) end

H.pv(">>>     In SearchModScriptForFileExt.lua")
THIS = "In SearchModScriptForFileExt: "
LDebug = false

-- gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"") --..[[\]] -- \ required because we are in AMUMSS folder
--gMASTER_FOLDER_PATH = H.LoadFileData(arg[2]..[[\MASTER_FOLDER_PATH.txt]])
-- print("X2: len(gMASTER_FOLDER_PATH) = "..string.len(gMASTER_FOLDER_PATH).." "..#gMASTER_FOLDER_PATH)
-- print("["..lfs.currentdir().."]")    --...AMUMSS
-- print("["..gMASTER_FOLDER_PATH.."]") --...AMUMSS\

H.gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"") --..[[\]] -- \ required because we are in AMUMSS folder
gPathToModScript = [[..\ModScript]]

EXT = arg[1]

local result = SearchModScriptForFileExt(EXT)

H.gfilePATH = "..\\" --for Report()
H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
-- print(" YYYYY result = ["..result.."]")
os.exit(result)