--arg[1] == string: file EXTensions to check
--arg[2] == string: path to MODBUILDER
--arg[3] == string: report too deep sub-folders
--arg[4] == string: report pathTooLongList
--arg[5] == string: Caller location
--arg[6] == string: "true" to display # of found files

-- LDebug = true

--Only files with EXT extensions in ModScript and sub-directory that do not contain DONOTUSE_name
function SearchModScriptForMultiFileExt(EXT,IsTooDeep,IsTooLongPaths)
  local p = function(...) return end --to disable
  if LDebug then p = print end --active
  
  local IsVerbose = arg[6] == "true"
  
  -- p("FROM SearchModScriptForMultiFileExt")
  H.GetModScriptValidContent(gPathToModScriptFromMain,IsVerbose)
  local ModScriptValidContent = H.gModScriptValidContent --for speed
  --local ScriptList = H.gScriptList --for speed
  -- H.printf("ModScriptValidContent = %d",#ModScriptValidContent)
  
  -- for i=1,#ModScriptValidContent do
    -- H.printf("ModScriptValidContent[%d][1] = [%s]",i,ModScriptValidContent[i][1])
  -- end
  
  if IsTooDeep then
    --now check and remove too deep sub-folders
    --like: Test_Combine_vs_Invividual\PubMods2\BAD_SUB_FOLDER
    local IsFirst = true
    local info = ""
    
    for i=1,#ModScriptValidContent do
      if ModScriptValidContent[i][2] ~= "" then
        if IsFirst then
          IsFirst = false
          print("")
        end
        if info ~= ModScriptValidContent[i][2] then
          -- print(">>> ["..info.."]")
          -- print("   >>> ["..ModScriptValidContent[i][2].."]")
          -- print("   >>> ["..ModScriptValidContent[i][2]:sub(1,#info).."]")
          if info == "" or ModScriptValidContent[i][2]:sub(1,#info) ~= info then
            print(H.gcNOTICE..[[>>> [NOTICE] ModScript sub-folder >>>]]..H._zDEFAULT..[[ ]]..H._zBRIGHTGREEN..ModScriptValidContent[i][2]..H._zDEFAULT..[[ ]]..H.gcNOTICE..[[<<< (and its sub-folders) are too deep and will not be used.]]..H._zDEFAULT)
            info = ModScriptValidContent[i][2]
          end
        end
      end
    end
    
    if IsFound then
      -- in this place, was not working for DarkScythe
      H.WFAK()
    end
  end
  
  if IsTooLongPaths then
    for i=1,#ModScriptValidContent do
      local IsFirst = true
      if ModScriptValidContent[i][3] ~= "" then
        if IsFirst then
          IsFirst = false
          print("")
          if #pathTooLongList > 1 then
            print(H.gcWARNING..[[>>> [WARNING] These paths are probably too long (> 260 char) and can cause problems.]]..H._zDEFAULT)
          else
            print(H.gcWARNING..[[>>> [WARNING] This path is probably too long (> 260 char) and can cause problems.]]..H._zDEFAULT)
          end
        end
        
        local tmp = trim(ModScriptValidContent[i][3])
        print("- "..tmp)
        H.Report("","- "..tmp)
      end
    end
  end
  
  -- H.printf("BEFORE looking for EXT")
  
  local ModScriptEXTDirList = {}
  local extCount = {}

  -- local NMSMainFolders = H.ParseTextFileIntoTable("NMSMainFolders.txt")
  -- local FastNMSMainFolders = ipairs.fastTable(NMSMainFolders)
  -- local ModScriptPath = lfs.currentdir():gsub([[MODBUILDER]],[[ModScript\]])
  
  --split EXT (like ".MBIN,.EXML,.MXML,.lua,.pak") into its extensions
  --and insert count into table
  local t = EXT:splitB(",")
  for i=1,#t do
    -- H.printf("=== ext = [%s]",t[i])
    
    local tmp
    if t[i]:upper() == ".LUA" then
      tmp = H.GetFilesWithExt(t[i],false) -- false: look into Modscript folder and sub-folders
    
    -- elseif t[i]:upper() == ".MXML" then
      -- tmp = H.GetFilesWithExt(t[i],false)
      -- for j=#tmp,1,-1 do
        -- local shortPath = tmp[j][1]:gsub(ModScriptPath,"")
        -- -- print(shortPath)
        -- local pos = string.find(shortPath,[[\]],1,true)
        -- if pos then
          -- local IsInModscript = FastNMSMainFolders[string.sub(shortPath,1,pos-1)]
          -- if not IsInModscript then
            -- table.remove(tmp,j)
          -- end
        -- end
      -- end
      
    else
      tmp = H.GetFilesWithExt(t[i],true) -- true: look only in ModScript folder, not sub-folders
    end

-- for j=1,#tmp do
  -- H.printf("-> %s: [%s]",t[i],tmp[j][1])
-- end

    extCount[#extCount+1] = {}
    extCount[#extCount][1] = t[i]
    extCount[#extCount][2] = #tmp

    -- for j=1,#tmp do
      -- ModScriptEXTDirList[#ModScriptEXTDirList+1] = tmp[j]
    -- end
  end
  
  local extCountString = ""
  for i=1,#extCount do
    extCountString = extCountString..extCount[i][1].."="..extCount[i][2]..", "
  end

  -- p("=== ["..string.sub(extCountString,1,-3).."]")
  -- p()

  -- write out info for bzrun.bat
  H.WriteToFile(string.sub(extCountString,1,-3),[[modscriptContent.txt]])

  -- p("=== Done")
  -- for i=1,#ModScriptEXTDirList do
    -- p(" - ["..ModScriptEXTDirList[i].."]")
  -- end
  
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER folder

LocalFolder = [[]]
IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile([[LoadHelpers.lua]]) end

H.pv(">>>     In SearchModScriptForMultiFileExt.lua")
THIS = "In SearchModScriptForMultiFileExt: "

EXT = arg[1] --like ".MBIN,.EXML,.MXML,.LUA"

H.gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"") --..[[\]] -- \ required because we are in AMUMSS folder
--gMASTER_FOLDER_PATH = H.LoadFileData(arg[2]..[[\MASTER_FOLDER_PATH.txt]])
-- print("gMASTER_FOLDER_PATH = ["..gMASTER_FOLDER_PATH.."]")
-- print("X1: len(gMASTER_FOLDER_PATH) = "..string.len(gMASTER_FOLDER_PATH).." "..#gMASTER_FOLDER_PATH)

gPathToModScriptFromMain = [[..\ModScript]]

IsTooLongPaths = (arg[4] == "TooLongPaths")
IsTooDeep = (arg[3] == "TooDeep")

if not (arg[5] == nil or arg[5] == "") then
  print()
  print("         @@@                Caller Id = ["..arg[4].."]")
  print("         @@@               currentdir = ["..lfs.currentdir().."]")  
  print("         @@@ gPathToModScriptFromMain = ["..gPathToModScriptFromMain.."]")
end

-- print("=== arg[i] = ["..arg[1].."]")
--local result = SearchModScriptForMultiFileExt(EXT)
-- print("IsTooDeep = "..tostring(IsTooDeep))
-- H.Report("",[[>>> This is SearchModScriptForMultiFileExt()]],"WARNING")
SearchModScriptForMultiFileExt(EXT,IsTooDeep,IsTooLongPaths)

H.gfilePATH = "..\\" --for Report()
H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)

--results returned thru modscriptContent.txt
