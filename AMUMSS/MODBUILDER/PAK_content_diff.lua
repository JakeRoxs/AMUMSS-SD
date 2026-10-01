
function PAK_content_diff(MainHashPath,previous_Hash,current_Hash,outputFolder)
  local pH,msg = H.ParseTextFileIntoTable(MainHashPath..previous_Hash)
  if string.sub(msg,1,5) == "ERROR" then
    print("Failed to load ["..MainHashPath..previous_Hash.."]")
    H.WFAK()
    return
  end

  local cH,msg = H.ParseTextFileIntoTable(MainHashPath..current_Hash)
  if string.sub(msg,1,5) == "ERROR" then
    print("Failed to load ["..MainHashPath..current_Hash.."]")
    H.WFAK()
    return
  end

  local previousPath = H.GetFolderPathFromFilePath(previous_Hash)
  previous = previous_Hash:sub(#previousPath+2):gsub([[.json]],[[]])

  local currentPath = H.GetFolderPathFromFilePath(current_Hash)
  current = current_Hash:sub(#currentPath+2):gsub([[.json]],[[]])

-- print()
-- print("previousPath = <"..previousPath..">")
-- print("previous = <"..previous..">")
-- print("currentPath = <"..currentPath..">")
-- print("current = <"..current..">")
-- H.WFAK("0: press a key...")
-- print()
    
  --****************************************************************
  local function splitJsonInfo(t)
    local info = {}
    
    -- skip 1st and last lines
    for i = 2, #t do
      local x = t[i]:splitB([[": ]])
      if x[2] then
        info[#info + 1] = {}
        info[#info][1] = x[1]:sub(4,-1)
        -- because last entry has no comma! (json idea!)
        info[#info][2] = x[2]:sub(2):gsub([["]],[[]]):gsub([[,]],[[]])
      end
    end
    
-- print("A: <"..info[#info][1]..">")
-- print("A: <"..info[#info][2]..">")
-- H.WFAK("A: press a key...")
    return info
  end
  --****************************************************************

  -- create simplified tables
  local cHx = splitJsonInfo(cH)
  local pHx = splitJsonInfo(pH)
-- print("cHx[#cHx][1] = <"..cHx[#cHx][1]..">")
-- print("cHx[#cHx][2] = <"..cHx[#cHx][2]..">")
-- print("pHx[#pHx][1] = <"..pHx[#pHx][1]..">")
-- print("pHx[#pHx][2] = <"..pHx[#pHx][2]..">")
-- H.WFAK("B: press a key...")

  -- create FAST tables
  local fcHx = H.fastTable(cHx)
  local fpHx = H.fastTable(pHx)

-- print("Test_c: <"..cHx[#cHx][2]..">: <"..cHx[#cHx][1]..">")
-- print("Test_c: <"..fcHx[cHx[#cHx][1]]..">")
-- print("Test_p: <"..pHx[#pHx][2]..">: <"..pHx[#pHx][1]..">")
-- print("Test_p: <"..fpHx[pHx[#pHx][1]]..">")
-- H.WFAK("C: press a key...")
  
  print("Diff report for "..previous.."-"..current)
  print("    currentHashTable size = "..#cHx)
  
  local diff_H = {}
  local NotFound_C = {}
  
  print("")
  print("Phase 1: find different and new files in current version:")
  for i = 1, #cHx do
    local iC = cHx[i][1]
    
    local h = fpHx[iC]
    if h then
      -- exist in previous
      if h ~= cHx[i][2] then
        -- diff hash
        diff_H[#diff_H+1] = iC
-- print("- <"..cHx[i][2]..">: <"..cHx[i][1]..">")
-- print("  <"..h..">")
-- -- H.WFAK()
      end
    else
      -- a new file
      NotFound_C[#NotFound_C+1] = iC
    end 
  end

-- print("#diff_H "..#diff_H)
-- print("#NotFound_C "..#NotFound_C)
-- H.WFAK("D: press a key...")
  
  table.sort(diff_H)
  table.sort(NotFound_C)

-- do
  -- return
-- end  
  -- print("")
  -- print("***********  RESULTS  ************")
  -- print(">>> Different files:")
  -- for i=1,#diff_H do
    -- print(string.format("- %s",diff_H[i]))
  -- end

  local filenamePath = outputFolder.."Diff_"..previous.."-"..current..[[.lua]]
  print("filenamePath = <"..filenamePath..">")

  H.WriteToFile("PCBANKS Diff report for "..previous.."-"..current.."\n",filenamePath)
  H.WriteToFileAppend(">>> Total files with different HASH: "..tostring(#diff_H).." {\n",filenamePath)
  H.WriteToFileAppend(H.ConvertLineTableToText(diff_H),filenamePath)
  
  -- print("")
  -- print(">>> New files:")
  -- for i=1,#NotFound_C do
    -- print(string.format("- %s",NotFound_C[i]))
  -- end

  H.WriteToFileAppend("\n}\n>>> New files: "..tostring(#NotFound_C).." {\n",filenamePath)
  H.WriteToFileAppend(H.ConvertLineTableToText(NotFound_C),filenamePath)
  
  print("")
  print("Phase 2: find removed files in previous version:")
  
  -- now find removed files from previous
  local NotFound_P = {}
  
  for i = 1, #pHx do
    local iP = pHx[i][1]
    
    local h = fcHx[iP]
    if h == nil then
      -- a removed file
      NotFound_P[#NotFound_P+1] = iP
    end     
  end

-- print("#NotFound_P "..#NotFound_P)
-- H.WFAK()

  table.sort(NotFound_P)
  
  -- print("")
  -- print(">>> Removed files:")
  -- for i=1,#NotFound_P do
    -- print(string.format("- %s",NotFound_P[i]))
  -- end

  H.WriteToFileAppend("\n}\n>>> Removed files: "..tostring(#NotFound_P).." {\n",filenamePath)
  H.WriteToFileAppend(H.ConvertLineTableToText(NotFound_P),filenamePath)
  H.WriteToFileAppend("\n}",filenamePath)

  -- now, create a reduced version without AUDIO and SHADER folders
  local diffTable = H.ParseTextFileIntoTable(filenamePath)
  
  local filenamePathMIN = outputFolder.."DiffMIN_"..previous.."-"..current..[[.lua]]
  
  local diffTableMIN = {}
  diffTableMIN[1] = "PCBANKS Diff report for "..previous.."-"..current.." (minus AUDIO and SHADERS folders)"
  
  local IsOkToSave = false
  for i=2,#diffTable do
    local s = diffTable[i]
    if string.match(s,[[^AUDIO]]) == nil and string.match(s,[[^SHADERS]]) == nil then
      diffTableMIN[#diffTableMIN+1] = diffTable[i]
    else
      IsOkToSave = true
    end
  end
  
  if IsOkToSave then
    -- only create when AUDIO or SHADERS folders are present
    H.WriteToFile(diffTableMIN,filenamePathMIN)
  end
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER

IsLightLoadHelper = true -- must be GLOBAL
LocalFolder = ""
if H == nil then dofile(LocalFolder.."LoadHelpers.lua") end
H.pv(">>>     In PAK_content_diff.lua")
THIS = "In PAK_content_diff: v1.0"
print(THIS)

-- H.gfilePATH = "..\\" --for Report()

startTime = os.clock()

-- print("<"..tostring(arg[1])..">")
-- print("<"..tostring(arg[2])..">")
-- print("<"..tostring(arg[3])..">")
-- print("<"..tostring(arg[4])..">")

-- H.WFAK()

MainHashPath = arg[1] -- input: folder to use
if MainHashPath == "w" then
  MainHashPath = ""
end
-- if MainHashPath == nil or MainHashPath == "" then
  -- print("Input: folder string is empty!")
  -- H.WFAK()
  -- return
-- end

current_Hash = arg[2] -- input: current json file to use
-- if current_Hash == nil or current_Hash == "" then
  -- print("Input: current json file string is empty!")
  -- H.WFAK()
  -- return
-- end

previous_Hash = arg[3] -- input: previous json file to use
-- if current_Hash == nil or current_Hash == "" then
  -- print("Input: previous json file string is empty!")
  -- H.WFAK()
  -- return
-- end

outputFolder = arg[4] -- ouput: folder to use
  -- NORMAL FORM: outputFolder = [[..\PAK_Diff]]
-- if outputFolder == nil or outputFolder == "" then
  -- print("Ouput: folder string is empty!")
  -- H.WFAK()
  -- return
-- end

-- DEBUG Options
-- PAK_content_diff.lua 'w' 
  -- 'C:\Users\Robert\source\repos\NMSPE-net5-6-ok\NMS PCBANKS Explorer\bin\Debug\net6.0-windows\NMSPE_Output\PAK_Content\Hash_v100958.json' 
  -- 'C:\Users\Robert\source\repos\NMSPE-net5-6-ok\NMS PCBANKS Explorer\bin\Debug\net6.0-windows\NMSPE_Output\PAK_Content\Hash_v100867.json' 
  -- 'C:\Users\Robert\Desktop\AMUMSS-4.0.0.0W\Diff\'

-- print()
-- print("MainHashPath = <"..MainHashPath..">")
-- print("current_Hash = <"..current_Hash..">")
-- print("previous_Hash= <"..previous_Hash..">")
-- print("outputFolder = <"..outputFolder..">")
-- H.WFAK()

PAK_content_diff(MainHashPath,previous_Hash,current_Hash,outputFolder)

print(H.dClock(os.clock() - startTime))

-- H.WFAK()
