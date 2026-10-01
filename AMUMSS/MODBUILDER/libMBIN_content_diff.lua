
function libMBIN_content_diff(MainContentPath,previous_Content,current_Content,outputFolder)
  local pC,msg = H.ParseTextFileIntoTable(MainContentPath..previous_Content)
  if string.sub(msg,1,5) == "ERROR" then
    print("Failed to load ["..MainContentPath..previous_Content.."]")
    H.WFAK()
    return
  end

  local cC,msg = H.ParseTextFileIntoTable(MainContentPath..current_Content)
  if string.sub(msg,1,5) == "ERROR" then
    print("Failed to load ["..MainContentPath..current_Content.."]")
    H.WFAK()
    return
  end

  local previousPath = H.GetFolderPathFromFilePath(previous_Content)
  if previousPath == "" then
    previous = previous_Content:gsub([[Content_libMBIN_]],[[]]):gsub([[.lua]],[[]])
  else
    previous = previous_Content:sub(#previousPath+2):gsub([[Content_libMBIN_]],[[]]):gsub([[.lua]],[[]])
  end

  local currentPath = H.GetFolderPathFromFilePath(current_Content)
  if currentPath == "" then
    current = current_Content:gsub([[Content_libMBIN_]],[[]]):gsub([[.lua]],[[]])
  else
    current = current_Content:sub(#currentPath+2):gsub([[Content_libMBIN_]],[[]]):gsub([[.lua]],[[]])
  end

  local filenamePath = outputFolder.."Diff_libMBIN_"..previous.."-"..current..[[.lua]]
  -- print("filenamePath = <"..filenamePath..">")
  
  --let us printout this list
  local outputFile = filenamePath

  --================================================================
  local function printout(...)
    -- print(...)
    H.WriteToFileAppendEXT(LocalFolder..outputFile,...)
  end
  --================================================================  
  
  os.remove(LocalFolder..outputFile)
  
  printout("Diff report for "..previous.."-"..current.."\n",filenamePath)

  -- print()
  -- print("previousPath = <"..previousPath..">")
  -- print("previous = <"..previous..">")
  -- print("currentPath = <"..currentPath..">")
  -- print("current = <"..current..">")
  -- -- H.WFAK("0: press a key...")
  -- print()

  -- create simplified tables
  local cCx = {}
  for i=1,#cC do
    local line = cC[i]
    if string.find(line," = {",1,true) and line ~= "INMSString = {" then
      cCx[#cCx+1] = string.sub(line,1,string.find(line," =") - 1)
    end
  end
  table.sort(cCx)
  
  local pCx = {}
  for i=1,#pC do
    local line = pC[i]
    if string.find(line," = {",1,true) and line ~= "INMSString = {" then
      pCx[#pCx+1] = string.sub(line,1,string.find(line," =") - 1)
    end
  end
  table.sort(pCx)
  
  -- print(string.sub(previous,1,-5).."-"..current)
  
  -- check for new structures
  printout()
  printout("ADDED Structures/Enum:")
  local IsDidOne = false
  for i=1,#cCx do
    local line = cCx[i]
    local found = false
    for j=1,#pCx do
      if line == pCx[j] then
        found = true
        break
      end
    end
    if not found then
      IsDidOne = true
      printout("  "..line)
    end
  end
  
  if not IsDidOne then
    printout("  *** None ***")
  end
  
  -- check for removed structures
  printout()
  printout("REMOVED Structures/Enum:")
  local IsDidOne = false
  for i=1,#pCx do
    local line = pCx[i]
    local found = false
    for j=1,#cCx do
      if line == cCx[j] then
        found = true
        break
      end
    end
    if not found then
      IsDidOne = true
      printout("  "..line)
    end
  end

  if not IsDidOne then
    printout("  *** None ***")
  end
  
  -- create one sub-table for each CURRENT structure with fields
  local cCf = {}
  local structName = ""
  for i=1,#cC do
    local line = cC[i]
    if string.find(line," = {",1,true) then
      -- the name of the structure
      structName = string.sub(line,1,string.find(line," =") - 1)
      cCf[structName] = {}
    elseif string.find(line,[[",]],1,true) then
      -- a field
      cCf[structName][#cCf[structName] + 1] = string.sub(line,2,-3)
    elseif string.find(line,"},",1,true) then
      -- reset, end of this structure
      structName = ""
    end
  end
  
  -- -- for display
  -- local sorted_cCf = {}
  -- for k,v in pairs(cCf) do
    -- for kk,vv in pairs(v) do
      -- sorted_cCf[#sorted_cCf+1] = string.format("%50s = [%s]",k,vv)
      -- -- print(string.format("%50s = [%s]",k,vv))
    -- end
  -- end
  -- -- needs a special function
  -- table.sort(sorted_cCf)
  
  -- for i=1,#sorted_cCf do
    -- print(sorted_cCf[i])
  -- end
  
  -- create one sub-table for each PREVIOUS structure with fields
  local pCf = {}
  local structName = ""
  local enumTable = {}
  local enumName = {}
  for i=1,#pC do
    local line = pC[i]
    if string.find(line," = {",1,true) then
      -- the name of the structure
      structName = string.sub(line,1,string.find(line," =") - 1)
      pCf[structName] = {}
    elseif string.find(line,[[",]],1,true) then
      if string.find(line,[[ = ]],1,true) then
        -- an enum
        local index,name = string.match(line,[[(%g*) = (%g*)",]]) -- [[(%w*) = ([%g]*)",]]
        -- H.printf("  = [%s] [%s]",index,name)
        if index and name then
          enumTable[name] = index
          enumName[index] = name
        end
      end
      -- a field
      pCf[structName][#pCf[structName] + 1] = string.sub(line,2,-3)
    elseif string.find(line,"},",1,true) then
      -- reset, end of this structure
      structName = ""
    end
  end
  
  local leftPos = 60

  -- compare CURRENT to PREVIOUS fields
  local tmp1 = {} -- added
  for i=1,#cCx do  -- for each CURRENT structure
    local structName = cCx[i]
    -- print("structName = ["..structName.."]")
    
    local CURRENTStruct = cCf[structName]
    for ck,cv in pairs(CURRENTStruct) do -- for each field in this structure
      -- print(string.format("%50s = [%s]",ck,cv))
      -- look for ADDED fields
      local pStructure = pCf[structName]
      if pStructure then
        -- CURRENT structure existed previously
        local found = false
        for i=1,#pStructure do
          local pField = pStructure[i]
          if cv == pField then
            -- found exact field
            found = true
            break           
          end
        end
        if not found then
          -- field cv not found, must be new
          tmp1[#tmp1 + 1] = {}
          tmp1[#tmp1][1] = structName
          tmp1[#tmp1][2] = string.format(" + %"..leftPos.."s = [%s]",structName,cv)
          --printout(string.format(" + %50s = [%s]",structName,cv))
        end
      else
        -- print(string.format(" + Structure %s",structName))
        break
      end
    end -- for ck,cv in pairs(thisStruct) do -- for each field in this structure
  end -- for i=1,#cCx do  -- for each CURRENT structure
  
  -- compare PREVIOUS to CURRENT fields
  local tmp2 = {} -- removed
  -- local tmp3 = {} -- changed
  for i=1,#pCx do  -- for each PREVIOUS structure
    local structName = pCx[i]
    
    -- if structName == "MaterialFlagEnum" then
      -- print("structName = ["..structName.."]")
    -- end
    
    local PREVIOUSStruct = pCf[structName]
    for pk,pv in pairs(PREVIOUSStruct) do -- for each field in this structure
      -- if structName == "MaterialFlagEnum" then
        -- print(string.format("%50s = [%s] previously",pk,pv))
      -- end
      
      -- look for REMOVED fields
      local cStructure = cCf[structName]
      if cStructure then
        -- PREVIOUS structure exist NOW
        -- look for removed fields in PREVIOUS structure
        local found = false
        for i=1,#cStructure do
          -- local cField = cStructure[i]
          if pv == cStructure[i] then
            -- found exact field
            found = true
            break           
          end
        end
        if not found then
          -- field pv not found, must be new or was moved
          if string.find(pv,[[ = ]],1,true) then
            -- an enum
            -- H.printf("an enum = [%s]",pv)
            local index,fieldName = string.match(pv,[[(%g*) = (%g*)]]) -- [[(%w*) = ([%g]*)]]
            
            -- if structName == "MaterialFlagEnum" then
              -- H.printf("    [%s] [%s]",index,fieldName)
            -- end
            
            if index and fieldName then
              if enumTable[fieldName] then
                -- a previous enum
                -- if structName == "MaterialFlagEnum" then
                  -- H.printf("      previous enum = [%s] [%s]",index,fieldName)
                  -- H.printf("      enumTable[%s] = [%s]",fieldName,index)
                -- end
                
                local previousIndex = enumTable[fieldName].."==>"
                
                -- if structName == "MaterialFlagEnum" then
                  -- H.printf("      previousIndex = [%s]",previousIndex)
                -- end
                
                local found = false
                for k=1,#tmp1 do
                  -- if tmp1[k][1] == "MaterialFlagEnum" then
                    -- H.printf("    tmp1[k][1] = [%s]",tmp1[k][1])
                    -- H.printf("    tmp1[k][2] = [%s]",tmp1[k][2])
                  -- end
                  
                  if tmp1[k][1] == structName then
                    if not string.find(tmp1[k][2],"==>",1,true) and string.find(tmp1[k][2],fieldName,1,true) then
                      tmp1[k][2] = string.gsub(tmp1[k][2],"%+","=")
                      local pos = string.find(tmp1[k][2],"[",1,true)
                      if pos then
                        tmp1[k][2] = string.sub(tmp1[k][2],1,pos)..previousIndex..string.sub(tmp1[k][2],pos+1)
                      end
                      found = true
                      break
                    end
                  end
                end
                
                if not found then
                  tmp2[#tmp2 + 1] = {}
                  tmp2[#tmp2][1] = structName
                  tmp2[#tmp2][2] = string.format(" - %"..leftPos.."s = [%s]",structName,pv)                  
                end
                
              else
                -- a new enum
                tmp2[#tmp2 + 1] = {}
                tmp2[#tmp2][1] = structName
                tmp2[#tmp2][2] = string.format(" - %"..leftPos.."s = [%s] a new enum",structName,pv)
                -- printout(string.format(" - %50s = [%s]",structName,pv))
              end
            end

          else
            -- a field
            tmp2[#tmp2 + 1] = {}
            tmp2[#tmp2][1] = structName
            tmp2[#tmp2][2] = string.format(" - %"..leftPos.."s = [%s]",structName,pv)
            -- printout(string.format(" - %50s = [%s]",structName,pv))
          end
        -- else
          -- -- field pv found in previous structure
          -- if structName == "MaterialFlagEnum" then
            -- print("    FOUND pv = ["..pv.."]")
          -- end
        end
      else
        -- print(string.format(" - Structure %s",structName))
        break
      end
    end
  end -- for i=1,#pCx do  -- for each PREVIOUS structure

  printout()
  printout("ADDED Fields:")
  
  -- to reverse the output order
  local IsDidOne = false
  local sName = ""
  for i=1,#tmp1 do
    if sName ~= tmp1[i][1] then
      sName = tmp1[i][1]
      for j=#tmp1,i,-1 do
        if tmp1[j][1] == sName and string.sub(tmp1[j][2],1,2) == " +" then
          IsDidOne = true
          printout(tmp1[j][2])
        else
          i = j + 1
        end
      end
    end
  end

  if not IsDidOne then
    printout("  *** None ***")
  end
  
  printout()
  printout("REMOVED Fields:")
  
  -- to reverse the output order
  local IsDidOne = false
  local sName = ""
  for i=1,#tmp2 do
    if sName ~= tmp2[i][1] then
      sName = tmp2[i][1]
      for j=#tmp2,i,-1 do
        if tmp2[j][1] == sName then
          IsDidOne = true
          printout(tmp2[j][2])
        else
          i = j + 1
        end
      end
    end
  end
  
  if not IsDidOne then
    printout("  *** None ***")
  end
  
  printout()
  printout("MOVED Fields:")
  
  -- to reverse the output order
  local IsDidOne = false
  local sName = ""
  for i=1,#tmp1 do
    if sName ~= tmp1[i][1] then
      sName = tmp1[i][1]
      for j=#tmp1,i,-1 do
        if tmp1[j][1] == sName and string.sub(tmp1[j][2],1,2) == " =" then
          IsDidOne = true
          printout(tmp1[j][2])
        else
          i = j + 1
        end
      end
    end
  end
  
  if not IsDidOne then
    printout("  *** None ***")
  end
  
  printout("")
  printout(H.dClock(os.clock() - startTime))

  do
    print()
    return
  end


  local filenamePath = outputFolder.."Diff_"..previous.."-"..current..[[.lua]]
  print("filenamePath = <"..filenamePath..">")
  
  H.WriteToFile("Diff report for "..previous.."-"..current.."\n",filenamePath)
  H.WriteToFileAppend(">>> Files with different Content: "..tostring(#diff_H).." {\n",filenamePath)
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
  
  -- now found removed files from previous
  local NotFound_P = {}
  
  for i = 1, #pCx do
    local iP = pCx[i][1]
    
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
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER

LocalFolder = ""
if H == nil then dofile(LocalFolder.."LoadHelpers.lua") end
H.pv(">>>     In libMBIN_content_diff.lua")
THIS = "In libMBIN_content_diff: v1.0"

-- H.gfilePATH = "..\\" --for Report()

startTime = os.clock()

-- print("<"..tostring(arg[1])..">")
-- print("<"..tostring(arg[2])..">")
-- print("<"..tostring(arg[3])..">")
-- print("<"..tostring(arg[4])..">")

-- H.WFAK()

MainContentPath = arg[1] -- input: folder to use
if MainContentPath == "w" then
  MainContentPath = ""
end
-- if MainContentPath == nil or MainContentPath == "" then
  -- print("Input: folder string is empty!")
  -- H.WFAK()
  -- return
-- end

current_Content = arg[2] -- input: current json file to use
-- if current_Content == nil or current_Content == "" then
  -- print("Input: current json file string is empty!")
  -- H.WFAK()
  -- return
-- end

previous_Content = arg[3] -- input: previous json file to use
-- if current_Content == nil or current_Content == "" then
  -- print("Input: previous json file string is empty!")
  -- H.WFAK()
  -- return
-- end

outputFolder = arg[4] -- ouput: folder to use
  -- NORMAL FORM: outputFolder = [[..\libMBIN_Diff]]
-- if outputFolder == nil or outputFolder == "" then
  -- print("Ouput: folder string is empty!")
  -- H.WFAK()
  -- return
-- end

-- DEBUG Options
-- libMBIN_content_diff.lua "w" 
  -- "G:\AMUMSS\NMSPE_Output\libMBIN_Content\Content_libMBIN_v4.10.0.2.lua" 
  -- "G:\AMUMSS\NMSPE_Output\libMBIN_Content\Content_libMBIN_v4.10.0.1.lua" 
  -- "G:\AMUMSS\NMSPE_Output\libMBIN_Diff\\"
  
-- print()
-- print("MainContentPath = <"..MainContentPath..">")
-- print("current_Content = <"..current_Content..">")
-- print("previous_Content= <"..previous_Content..">")
-- print("outputFolder = <"..outputFolder..">")
-- H.WFAK()

libMBIN_content_diff(MainContentPath,previous_Content,current_Content,outputFolder)

-- H.WFAK()
