function DisplayMapFileTreeEXT(EXML,filename,IsLanguageEXML)
  local string = string
    local strsub = string.sub
    local strgsub = string.gsub
    local strfind = string.find
    local strlen = string.len -- much better to use #, if you can
    local strupper = string.upper
    local strrep = string.rep
    local strformat = string.format
    local strmatch = string.match
  local print = print
  local tostring = tostring
  local tonumber = tonumber
  local type = type
  local table = table
  local math = math
  local os = os

  H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: received request to process file ["..filename.."]\n",Runner)
  
  local KEY_WORDS = {}
  local TREE_LEVEL = {}
  local FILE_LINE = {}
  local COMMENT = {}
  local level = 0
  local STRUCT = {}
  local fileSTRUCTline = {}
  local fileSTRUCTlevel = {}
  
  if type(EXML) ~= "table" then
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: returned 'EXML is not a TABLE'\n",Runner)
    return "ERROR" 
  end
  if #EXML <= 1 then
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: returned 'TABLE is EMPTY'\n",Runner)
    return "ERROR" 
  end

  --***************************************************************************************************  
  local function FindKeywordsInLine(text,i)
      local value = H.StripInfo(text,[[ue="]],[["]])
      local name = H.StripInfo(text,[[me="]],[["]])
      return {strformat("%8u",i),name,value}
  end
  --***************************************************************************************************  
-- H.WFAK("A0")  

  --***************************************************************************************************
  local function GetProperLine(text)
    local s,indexInfo = strmatch(text,[[.+(<.+) _.+"(.+)"]])
    if s == nil then
      s = strmatch(text,".+(<.+)>")
    end
    if s then
      return strupper(s), indexInfo -- to make it case-insensitive
    end
    return text, ""
  end
  --***************************************************************************************************

  --***************************************************************************************************
  --EXML = table of the file
  --j = where to start in the table
  --returns kwType, a table
  local function FastEXML_UNIQUEtable(EXML,j)
    local kwType = {}
    local kwI = {}
    for i = j+1, #EXML-1 do
      local line,indexInfo = GetProperLine(EXML[i])
      if strfind(line,"ME=",1,true) then
        if kwType[line] == nil then
          kwType[line] = "SU" -- Special and Unique
        elseif kwType[line] == "SU" then
          kwType[line] = "S" -- Special, not unique
        end
      end
      
      kwI[i] = indexInfo or ""
      
    end
    return kwType, kwI
  end
  --***************************************************************************************************

  dofile("NMSstrings.lua")
  
  local posX = ""
  local posY = ""
  local posZ = ""
  local posA = ""
  local posB = ""
  local posC = ""

  if false then
    posX = "X"
    posY = "Y"
    posZ = "Z"
    posA = "A"
    posB = "B"
    posC = "C"
  end

  local structIndent = 4
  local structLevel = tonumber(H.LoadFileData("FileStructureLevel.txt"))
  local numLinesToProcess_Skip = 0
    
  --skipping a few lines at start
  local j = 0
  repeat
    j = j + 1
    if EXML[j] == nil then break end
  until string.find(EXML[j],[[te=]],1,true)
  
-- H.WFAK("B Before long")
  -- pre-process the exml for SPECIAL UNIQUE
  local kwType, kwI = FastEXML_UNIQUEtable(EXML,j)
-- H.WFAK("B After Long")
  
  -- local WholeTextFile = table.concat(EXML,"\n")
  
  local Pak_FileName = H.LocatePAK(filename)
  local Pak_FileNamePath = NMS_PCBANKS_FOLDER_PATH..Pak_FileName
  local fileInfo = string.gsub(filename,[[\]],[[.]])
  local filepathname = [[..\TOOLS\MapFileTrees\]]..fileInfo
  local fileStructPathname = [[..\TOOLS\FileStructures\]]..fileInfo:gsub(".MXML",".struct")..".py"
  -- local fileStructPathname = [[..\TOOLS\FileStructures\]].."test.txt"
  local OLDfilepathname = ""
  
  if H._mUSE_TXT_MAPFILETREE then
    --try deleting old other version
    OLDfilepathname = filepathname..".lua"
    if H.IsFileExist(OLDfilepathname) then
      --os.remove(OLDfilepathname)    --don't use, can get stuck
      -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
      os.execute([[START /B /wait "" /MIN cmd /c Del /f /q "]]..OLDfilepathname..[[" 1>NUL 2>NUL]])    
    end
    filepathname = filepathname..".txt"

  else --use default
    H._mUSE_LUA_MAPFILETREE = true

    --try deleting old other version
    OLDfilepathname = filepathname..".txt"
    if H.IsFileExist(OLDfilepathname) then
      --os.remove(OLDfilepathname)    --don't use, can get stuck
      -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
      os.execute([[START /B /wait "" /MIN cmd /c Del /f /q "]]..OLDfilepathname..[[" 1>NUL 2>NUL]])  
    end
    filepathname = filepathname..".lua"

  end
  
  -- print("      Creating MapFileTree...")
  -- print("XYZ = "..filename)
  
  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>>   Pak_FileNamePath = ["..Pak_FileNamePath.."]\n",Runner)
  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>>       filepathname = ["..filepathname.."]\n",Runner)
  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>> fileStructPathname = ["..fileStructPathname.."]\n",Runner)

  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>>                          H.IsFileExist(filepathname) = ["..tostring(H.IsFileExist(filepathname)).."]\n",Runner)
  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>>                    H.IsFileExist(fileStructPathname) = ["..tostring(H.IsFileExist(fileStructPathname)).."]\n",Runner)

  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>>       H.IsFile2Newest(Pak_FileNamePath,filepathname) = ["..tostring(H.IsFile2Newest(Pak_FileNamePath,filepathname)).."]\n",Runner)
  -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>> H.IsFile2Newest(Pak_FileNamePath,fileStructPathname) = ["..tostring(H.IsFile2Newest(Pak_FileNamePath,fileStructPathname)).."]\n",Runner)

  local IsUpdateNotNeeded = true
  if H.IsFile2Newest(Pak_FileNamePath,filepathname) then
    --the MapFileTree file is newest than the NMS pak file
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>> 'this MapFileTree is up-to-date!'\n",Runner)
  else
    IsUpdateNotNeeded = false
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>> 'this MapFileTree is outdated!'\n",Runner)
  end
  
  if H.IsFile2Newest(Pak_FileNamePath,fileStructPathname) then
    --the Structure file is newest than the NMS pak file
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>> 'this Structure is up-to-date!'\n",Runner)
  else
    IsUpdateNotNeeded = false
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: >>> 'this Structure is outdated!'\n",Runner)
  end
  
  if IsUpdateNotNeeded then
    return "UP_TO_DATE"
  end
  
  -- if H.IsFileExist(filepathname) then
    -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: deleting old version: '"..filepathname.."'\n",Runner)
    -- -- os.remove([["]]..filepathname..[["]])  --don't use, can get stuck
    -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
    -- os.execute([[START /B /wait "" /MIN cmd /c Del /f /q /s "]]..filepathname..[[" 1>NUL 2>NUL]])
  -- end
  
  local count = 10000
  if #EXML > count * 1000 then
    count = 1000000
  elseif #EXML > count * 100 then
    count = 100000
  elseif #EXML > count * 10 then
    count = 10000
  end
  -- local lineCount = 0
  
  -- if gUseNumCores <= 0 then
    -- --disable other processes
    -- IsLanguageEXML = false
  -- end
-- H.WFAK("C")  
  
  -- if not H.IsFileExist(os.getenv("SYSTEMROOT")..[[\system32\tasklist.exe]]) then
    -- --disable for OS that do not have it
    -- IsLanguageEXML = false
  -- end
  
  if IsLanguageEXML then
    -- local ProcessInfo = os.capture([[tasklist /FI "ImageName eq luaS.exe"]])
    -- --H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: ProcessInfo = ["..ProcessInfo.."]",Runner)
    
    -- local _,numUsedSlots = string.gsub(ProcessInfo,"luaS.exe","")
        
    -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: free slots = "..numUsedSlots.."/"..gUseNumCores.."\n",Runner)
    -- if numUsedSlots >= gUseNumCores then
      -- --skip this one for now
      -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: 'waiting' to activate SLAVE\n",Runner)
      -- local returnMsg = "SKIP"
      -- return returnMsg
      
    -- else
      -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: 'activating' SLAVE\n",Runner)
      
      -- local arg1 = filename
      -- local cmd = [[runThisJob.exe ".\]]..H._mLUAS..[[ CreateSlaveMapFileTree.lua ]]..arg1..[["]]
      -- -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: ["..cmd.."]\n",Runner)

      -- os.execute(cmd)
      
      -- local returnMsg = "OK"
      -- return returnMsg
    -- end
    
    -- print("\n     ==> LANGUAGE file, be patient...")
    local function WTFA(...)
      -- H.WriteToFileAppend(...)
      print(...)
    end

    local Language = ""
    local value = ""
    
    local startOfSection = j + 2
    local ValueLineOffsetInSection = 0
    local IdLineOffsetInSection = 1
    
    local sectionSize = startOfSection
    local s = strsub(EXML[startOfSection],1,12)
    local IsFoundLanguage = false
    
-- H.WFAK("C0")  
    for i = startOfSection + 1, #EXML do
      --get size of TkLocalisationEntry.xml section
      if s == strsub(EXML[i],1,12) then
        sectionSize = i - sectionSize
        break
      end
      --look ahead for the 'not empty' language value
      if not IsFoundLanguage and not strfind(strupper(EXML[i]),[[ NAME="ID"]],1,true) and not strfind(EXML[i],[[ value=""]],1,true) then
        -- if H.StripInfo(EXML[i],[[ue="]],[[" />]]) ~= [[]] then
          --found a non-empty value
          ValueLineOffsetInSection = i - startOfSection
          value = H.StripInfo(EXML[i],[[ue="]],[[" />]])
          Language = H.StripInfo(EXML[i],[[me="]],[[" value=]])
          IsFoundLanguage = true
        -- end
      end
    end
-- H.WFAK("C1")  
    
    WTFA(deltaX().."      DMFE: LANGUAGE is <"..Language..">")
    WTFA(deltaX().."      DMFE: section Size = ["..sectionSize.."]")
    WTFA(deltaX().."      DMFE: start of 1st section at ["..startOfSection.."]")
    WTFA(deltaX().."      DMFE: 'Id' found at OFFSET ["..IdLineOffsetInSection.."]")
    WTFA(deltaX().."      DMFE: this language 'value=' found at OFFSET ["..ValueLineOffsetInSection.."] ["..value.."]")
    
    --[[ looks like
    <Data template="cTkLocalisationTable"> -- j
      <Property name="Table"> -- j + 1
        <Property name="Table" value="TkLocalisationEntry" _id="UI_VR_RECENTRE"> -- startOfSection
          <Property name="Id" value="UI_VR_RECENTRE" /> -- startOfSection + IdLineOffsetInSection
          <Property name="English" value="Recentre VR View" /> -- startOfSection + ValueLineOffsetInSection
          <Property name="French" value="" />
          <Property name="Italian" value="" />
          <Property name="German" value="" />
          <Property name="Spanish" value="" />
          <Property name="Russian" value="" />
          <Property name="Polish" value="" />
          <Property name="Dutch" value="" />
          <Property name="Portuguese" value="" />
          <Property name="LatinAmericanSpanish" value="" />
          <Property name="BrazilianPortuguese" value="" />
          <Property name="SimplifiedChinese" value="" />
          <Property name="TraditionalChinese" value="" />
          <Property name="TencentChinese" value="" />
          <Property name="Korean" value="" />
          <Property name="Japanese" value="" />
          <Property name="USEnglish" value="" />
        </Property> -- startOfSection + sectionSize - 1
        <Property name="Table" value="TkLocalisationEntry" _id="UI_PADOPTION_STICKS">
          <Property name="Id" value="UI_PADOPTION_STICKS" />
          <Property name="English" value="Sticks: Smooth Turns" />
          <Property name="French" value="" />
          ...
      </Property> -- #EXML - 1
    </Data> --#EXML

    -- -- -- <Data template="TkLocalisationTable"> -- j
      -- -- -- <Property name="Table"> -- j + 1
      
        -- -- -- <Property value="TkLocalisationEntry.xml"> -- startOfSection
          -- -- -- <Property name="Id" value="UPDATE6_TITLE" /> -- startOfSection + IdLineOffsetInSection
          -- -- -- <Property name="USEnglish" value="VariableSizeString.xml"> -- startOfSection + ValueLineOffsetInSection - 1
            -- -- -- <Property name="Value" value="No Man's Sky Origins Update" /> -- startOfSection + ValueLineOffsetInSection
          -- -- -- </Property> -- startOfSection + sectionSize - 2
        -- -- -- </Property> -- startOfSection + sectionSize - 1
        
      -- -- -- </Property> -- #EXML - 1
    -- -- -- </Data> --#EXML
    --]]
        
    --[[ looks like
    >>> MapFileTree: LANGUAGE\NMS_LOC6_ENGLISH.EXML (NMSARC.86055253.pak) "2022/03/18-18:20:40"
     [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number
     TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique
     TYPE:FILELINE:LEVEL     KEYWORDS
    {[   :       3: 0]TkLocalisationTable --Do not use, NOT a KEYWORD
    {[P..:       4: 1]  "Table",
    {[P..:       5: 2]  | "TkLocalisationEntry.xml",
    :[.SU:       6: 3]  | | {"Id","UPDATE6_TITLE",},
    {[PS.:       7: 3]  | | "English", / {"English","VariableSizeString.xml",},
    :[.SU:       8: 4]  | | | {"Value","No Man's Sky Origins Update",},
    :[   :       9: 3]  | | <<< }
    :[   :  552424: 2]  | <<< }
    :[   :  552425: 1]  <<< }
    :[   :  552426: 0]/Data } --Do not use, NOT a KEYWORD
     TYPE:FILELINE:LEVEL     KEYWORDS
     TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique
     [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number
    >>> MapFileTree: LANGUAGE\NMS_LOC6_ENGLISH.EXML (NMSARC.86055253.pak) "2022/03/18-18:20:40"
    --]]

    --overwrite the previous one
    local function WTFA(...)
      ----H.WriteToFileAppend(...)
    end

-- local time = os.clock()

    -- WTFA(deltaX().."      DMFE: A["..EXML[j].."]\n",Runner)
    --TkLocalisationTable --Do not use, NOT a KEYWORD
    FILE_LINE[#FILE_LINE+1] = j
    TREE_LEVEL[#TREE_LEVEL+1] = level
    KEY_WORDS[#KEY_WORDS+1] = H.StripInfo(EXML[j],[[te=]],[[>]]) --remembers template
    COMMENT[#COMMENT+1] = [[   ]]
    
    level = level + 1
    
    -- WTFA(deltaX().."      DMFE: B["..EXML[j+1].."]\n",Runner)
    --P.. "Table"
    table.insert(FILE_LINE,j+1)
    table.insert(TREE_LEVEL,level)
    table.insert(KEY_WORDS, H.StripInfo(EXML[j+1],[[Property name=]],[[>]])..",") --remembers name
    table.insert(COMMENT, [[P..]])
    level = level + 1

    --for each section in the LANGUAGE EXML
    local startCount = count * 10
    local total = #EXML-3

    -- print("")
    -- print("     ==> Working...")
    -- lineCount = startOfSection
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: total lines to process = "..#EXML.." (starts at "..startOfSection..")\n",Runner)

    for i=startOfSection, total, sectionSize do
      -- lineCount = lineCount + 1
      if i > startCount then 
        startCount = startCount + (count * 10)
        H.WriteToFileAppend(deltaX().."      DMFE: "..i.." lines processed\n",Runner)
        -- print(strformat(H._zUpOneLineErase.."     ==> %u / %u",i,total))
      end
      
      -- WTFA(deltaX().."      DMFE: C["..EXML[i].."]\n",Runner)
      level = level + 1
      --P.. "TkLocalisationEntry.xml"
      -- table.insert(FILE_LINE,i)
      -- table.insert(TREE_LEVEL,level)
      -- table.insert(KEY_WORDS, H.StripInfo(EXML[i],[[=]],[[">]]))
      -- table.insert(COMMENT, [[   ]])

      -- WTFA(deltaX().."      DMFE: D["..EXML[i + IdLineOffsetInSection].."]\n",Runner)
      --.SU {"Id","...",},
      
      local nextLine = i + IdLineOffsetInSection
      local text = EXML[nextLine]
      local properText = GetProperLine(text)
      
      local kwi = kwI[i] or ""
      if kwi ~= "" then
        kwi = " ["..kwi.."]"
      end
            
      local Name = ""
      if strfind(text,[[me=]],1,true) and strfind(text,[[ue=]],1,true) then
        Name = H.StripInfo(text,[[me="]],[[" value=]])
      end
      
      if Name ~= "" then
        -- result = {lineNumber, name, value}
        local result = FindKeywordsInLine(text,nextLine)
        
        if result[1] ~= "" then
          --like: <Property name="Filename" value="MODELS/PLANETS/BIOMES/BARREN/HQ/TREES/DRACAENA.SCENE.MBIN" />
          --like: <Property name="Id" value="DRONE" />
          --like: <Property name="CreatureType" value="" />
          --like: ...
          FILE_LINE[#FILE_LINE+1] = nextLine
          TREE_LEVEL[#TREE_LEVEL+1] = level

          local value = result[3] -- H.StripInfo(result,[[=]],"]}")
          
          local UniqueMsg = [[   ]]
          if value ~= "" then
            UniqueMsg = [[.S.]]
            if kwType[properText] == "SU" then
            -- if secondPos == nil then
              UniqueMsg = [[.SU]]
              -- if value == [["True"]] or value == [["False"]] or tonumber(strsub(value,2,-2)) then
              if value == [[True]] or value == [[False]] or tonumber(value) then
                UniqueMsg = [[.su]]
              end
            
            -- elseif value == [["True"]] or value == [["False"]] or tonumber(strsub(value,2,-2)) then
            elseif value == [[True]] or value == [[False]] or tonumber(value) then
              UniqueMsg = [[.s.]]
            end
          end

          KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..value..[[",},]]..kwi --remembers name and value
          COMMENT[#COMMENT+1] = UniqueMsg
          
          STRUCT[#STRUCT+1] = strformat("%32s   {",result[3])
          
        end
      end

      -- WTFA(deltaX().."      DMFE: E["..EXML[i + ValueLineOffsetInSection - 1].."]\n",Runner)
      --P.. "English", -- NOT USED HERE / {"English","VariableSizeString.xml",},
      local offsetLine = i + ValueLineOffsetInSection - 1
      -- local text = EXML[offsetLine]
      -- FILE_LINE[#FILE_LINE+1] = offsetLine
      -- TREE_LEVEL[#TREE_LEVEL+1] = level

      -- local name = H.StripInfo(text,[[me=]],[[ value=]]) --remembers name
      -- KEY_WORDS[#KEY_WORDS+1] = name..","
      -- COMMENT[#COMMENT+1] = [[P..]]

      -- WTFA(deltaX().."      DMFE: F["..EXML[i + ValueLineOffsetInSection].."]\n",Runner)
      --.SU {"Value","No Man's Sky Origins Update",},
      -- level = level + 1
      FILE_LINE[#FILE_LINE+1] = offsetLine + 1
      TREE_LEVEL[#TREE_LEVEL+1] = level

      -- result = {lineNumber, name, value}
      local result = FindKeywordsInLine(EXML[offsetLine + 1],offsetLine + 1)
      -- local value = [["]]..result[3]..[["]] -- H.StripInfo(result,[[=]],"]")
      -- KEY_WORDS[#KEY_WORDS+1] = [[{"]]..H.StripInfo(result,[[: ]],[[=]])..[[",]]..value..[[,},]] --remembers name and value
      KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..result[3]..[[",},]] --remembers name and value
      COMMENT[#COMMENT+1] = [[.SU]]

      -- add plain text value
      FILE_LINE[#FILE_LINE+1] = offsetLine + 1
      TREE_LEVEL[#TREE_LEVEL+1] = level
      KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..H.CharEntitiesReverse(result[3])..[[",},]] --remembers name and value
      COMMENT[#COMMENT+1] = [[xxx]]
      
      STRUCT[#STRUCT] = STRUCT[#STRUCT]..H.CharEntitiesReverse(result[3]).."}"
      
      -- WTFA(deltaX().."      DMFE: G["..EXML[i + sectionSize - 2].."]\n",Runner)
      --<<<
      -- table.insert(FILE_LINE,i + sectionSize - 2)
      -- table.insert(TREE_LEVEL,level)
      -- table.insert(KEY_WORDS, "<<< }") --remembers end of section
      -- table.insert(COMMENT, [[   ]])
      -- level = level - 1

      -- WTFA(deltaX().."      DMFE: H["..EXML[i + sectionSize - 1].."]\n",Runner)
      --<<<
      -- table.insert(FILE_LINE,i + sectionSize - 1)
      -- table.insert(TREE_LEVEL,level)
      -- table.insert(KEY_WORDS, "<<< }") --remembers end of section
      -- table.insert(COMMENT, [[   ]])
      level = level - 1
    end -- for i=startOfSection, total, sectionSize do
    
    level = level - 1

    --<<< to close "Table"
    FILE_LINE[#FILE_LINE+1] = #EXML - 1
    TREE_LEVEL[#TREE_LEVEL+1] = level
    KEY_WORDS[#KEY_WORDS+1] = "<<< }" --remembers end of section
    COMMENT[#COMMENT+1] = [[   ]]

    level = level - 1
    -- WTFA(deltaX().."      DMFE: I["..EXML[#EXML - 1].."]\n",Runner)

    --/Data } --Do not use, NOT a KEYWORD
    FILE_LINE[#FILE_LINE+1] = #EXML
    TREE_LEVEL[#TREE_LEVEL+1] = level
    KEY_WORDS[#KEY_WORDS+1] = "/Data }" --remembers "/Data"
    COMMENT[#COMMENT+1] = [[   ]]

    -- WTFA(deltaX().."      DMFE: J["..EXML[#EXML].."]\n",Runner)

    print(strformat("     ==> %u / %u",total,total))
    --print(strformat(H._zUpOneLineErase.."     ==> %u / %u",total,total))

-- print(" #FILE_LINE = [ "..#FILE_LINE.."]")
-- print("#TREE_LEVEL = [ "..#TREE_LEVEL.."]")
-- print(" #KEY_WORDS = [ "..#KEY_WORDS.."]")
-- print("   #COMMENT = [ "..#COMMENT.."]")

-- local elapsed = os.clock()-time
-- print(tostring(elapsed).." END")
-- print(strformat("sec/1000 lines = %f",(elapsed/total)*1000))
-- H.WFAK("END")

  -- ##############################################
  else --all other EXML files
    -- local WholeTextFile = H.LoadFileData(gSourcePath..filename) --the EXML file as one string, for speed searching for uniqueness
-- H.WFAK("D")  
  
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: total lines to process = "..#EXML.." (starts at "..j..")\n",Runner)

    local total = #EXML
    for i=j,total do
      -- lineCount = lineCount + 1
      if i%count == 0 then 
        H.WriteToFileAppend(deltaX().."      DMFE: "..i.." lines processed\n",Runner)
      end

      local text = EXML[i]
      local properText = GetProperLine(text)
      local kwi = kwI[i] or ""
      if kwi ~= "" then
        kwi = " ["..kwi.."]"
      end
      
      local result = FindKeywordsInLine(text,i)
      -- result[1] = line number
      -- result[2] = name
      -- result[3] = value
      
      if string.find(text,[[/>]],1,true) then
        --ALL lines with "/>"
        -- never a List<> or Array
        local Name = ""
        if string.find(text,[[me=]],1,true) and string.find(text,[[ue=]],1,true) then
          Name = H.StripInfo(text,[[me="]],[[" value=]])
        end
        
        if Name ~= "" then
          if result[1] ~= "" then
            --like: <Property name="Filename" value="MODELS/PLANETS/BIOMES/BARREN/HQ/TREES/DRACAENA.SCENE.MBIN" />
            --like: <Property name="Id" value="DRONE" />
            --like: <Property name="CreatureType" value="" />
            --like: ...
            FILE_LINE[#FILE_LINE+1] = i
            TREE_LEVEL[#TREE_LEVEL+1] = level + 1
            
            local value = result[3] -- H.StripInfo(result,[[=]],"]}")
            
            local UniqueMsg = [[   ]]
            if value ~= "" or strfind(text,[[ue="" />]],1,true) then
              UniqueMsg = [[.S.]]
              if kwType[properText] == "SU" then
                UniqueMsg = [[.SU]]
                if value == [[True]] or value == [[False]] or tonumber(value) then
                  UniqueMsg = [[.su]]
                end
              
              elseif value == [[True]] or value == [[False]] or tonumber(value) then
                UniqueMsg = [[.s.]]
              end
            end
            
            if numLinesToProcess_Skip and numLinesToProcess_Skip > 0 then
              numLinesToProcess_Skip = numLinesToProcess_Skip - 1
            elseif structLevel == 3 then
              STRUCT[#STRUCT+1] = posX..strrep(" ",(level+1)*structIndent)..result[2]..":'"..value.."'"..kwi.."{"
              fileSTRUCTline[#fileSTRUCTline+1] = i
              fileSTRUCTlevel[#fileSTRUCTlevel+1] = level + 1
            end
            
            local ENUM = ""
            if enumsK[result[2]] then
              ENUM = " -- ENUM"
            end
            KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..value..[[",},]]..kwi..ENUM --remembers name and value
            COMMENT[#COMMENT+1] = UniqueMsg
          else
            --like: <Property name="Seed" value="0" />
            --level = level + 1
            FILE_LINE[#FILE_LINE+1] = i
            TREE_LEVEL[#TREE_LEVEL+1] = level + 1
            KEY_WORDS[#KEY_WORDS+1] = [["]]..result[3]..[["]]..kwi
            COMMENT[#COMMENT+1] = [[   ]]

            STRUCT[#STRUCT+1] = posY..strrep(" ",level*structIndent)..KEY_WORDS[#KEY_WORDS]..kwi.."{"
            fileSTRUCTline[#fileSTRUCTline+1] = i
            fileSTRUCTlevel[#fileSTRUCTlevel+1] = level + 1
          end
        else
          --like: <Property value="3" /> or <Property name="VROverrides" />
          --level = level + 1
          FILE_LINE[#FILE_LINE+1] = i
          TREE_LEVEL[#TREE_LEVEL+1] = level + 1
          KEY_WORDS[#KEY_WORDS+1] = H.StripInfo(text,[[=]],[[ />]])..kwi

            if numLinesToProcess_Skip and numLinesToProcess_Skip > 0 then
              numLinesToProcess_Skip = numLinesToProcess_Skip - 1
            elseif structLevel == 3 then
              STRUCT[#STRUCT+1] = posZ..strrep(" ",(level+1)*structIndent)..KEY_WORDS[#KEY_WORDS]..kwi.."{"
              fileSTRUCTline[#fileSTRUCTline+1] = i
              fileSTRUCTlevel[#fileSTRUCTlevel+1] = level + 1
            end
          if strfind(text,[[ue=]],1,true) then
            --like: <Property value="3" />
            COMMENT[#COMMENT+1] = [[V..]]
          else
            --like: <Property name="VROverrides" />
            -- could be a HOES (Head Of Empty Section)
            COMMENT[#COMMENT+1] = [[H..]]
            -- KEY_WORDS[#KEY_WORDS] = KEY_WORDS[#KEY_WORDS] -- .." -- List<>"  
          end
        end
      
      -- #######################################################
      -- from here on, no lines with "/>".  Only lines with ">"
      elseif strfind(text,[[</Property>]],1,true) then
        --like: </Property>
        --NEVER a KEY_WORD but should remove preceding KEY_WORD
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = "<<< }" --remembers end of section
        COMMENT[#COMMENT+1] = [[   ]]
        level = level - 1

        STRUCT[#STRUCT] = STRUCT[#STRUCT].."}"
        -- fileSTRUCTline[#fileSTRUCTline+1] = i
        
      elseif strfind(text,[[me=]],1,true) and strfind(text,[[ue=]],1,true) then
        -- a Head of a Section: HOS
        --like: <Property name="ProceduralTexture" value="TkProceduralTextureChosenOptionList.xml">        
        level = level + 1
        
        STRUCT[#STRUCT+1] = posA..strrep(" ",level*structIndent)..result[2]..":'"..result[3].."'"..kwi.."{"
        fileSTRUCTline[#fileSTRUCTline+1] = i
        fileSTRUCTlevel[#fileSTRUCTlevel+1] = level

        if structLevel > 1 then
          numLinesToProcess_Skip = NMSstrings[strsub(result[3],1,-5)]
          -- if numLinesToProcess_Skip == nil then
            -- numLinesToProcess_Skip = 1 -- default
          -- end
          if numLinesToProcess_Skip then
            for n=1,numLinesToProcess_Skip do
              local _,_,val = table.unpack(FindKeywordsInLine(EXML[i+n],i+n))
              if val then
                STRUCT[#STRUCT] = STRUCT[#STRUCT].." ('"..val.."')"
              end
            end
            STRUCT[#STRUCT] = STRUCT[#STRUCT]:gsub("%) %(",",")
          end
        end
        
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        
        local name = H.StripInfo(text,[[me=]],[[ value=]]) --remembers name --Wbertro
        local specialName = ""
        
        -- if name ~= result[2] then
          -- -- ["name"] ~= [result[2]]
          -- print("==> ["..name.."] ~= ["..result[2].."]")
        -- end
        
        --this could also be a SPECIALNAME
        --like: <Property name="Rarity" value="GcRarity.xml">
        local value = result[3]
        local UniqueMsg = [[PS.]]
        if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil then
          if kwType[properText] == "SU" then
            UniqueMsg = [[PSU]]
            if value == "True" or value == "False" or tonumber(value) then
              UniqueMsg = [[Psu]]
            end
          end
          specialName = [[ / {]]..name..[[,"]]..value..[[",},]]
        elseif value == "True" or value == "False" or tonumber(value) then
          UniqueMsg = [[Ps.]]
        end

        KEY_WORDS[#KEY_WORDS+1] = name..","..specialName..kwi
        
        if specialName ~= "" then
          COMMENT[#COMMENT+1] = UniqueMsg
        else
          COMMENT[#COMMENT+1] = [[   ]]
        end
        
      elseif strfind(text,[[me=]],1,true) then
        --here there is NO value
        --   could be a List<> or Array/Enum
        --like: <Property name="Landmarks">
        
        local arrayInfo = ""
        if strfind(text,[[array_size=]],1,true) then
          arrayInfo = strmatch(text,[[(array_size=".-")]])
-- H.WriteToFileAppend(deltaX().."     DEBUG: "..strformat("%d: [%s] <%s>",i,EXML[i],arrayInfo).."\n",Runner)
        end
        
        local Type = "" -- ", name = "..name
        if arrayInfo ~= "" then
          Type = " -- "..arrayInfo
        else
          if i < total then
            -- -- get the name:
            local name = H.GetProperty(text) --remembers name --Wbertro
            -- local name = H.StripInfo(text,[[me=]],[[ value=]]) --remembers name --Wbertro

            -- H.WriteToFileAppend(deltaX().."     DEBUG: "..strformat("%d: %s",i,EXML[i]).."\n",Runner)
            --   looking ahead:
            local p,v = H.GetPropertyNameValue(EXML[i + 1])
            -- H.WriteToFileAppend(deltaX().."          : "..strformat("%d: name=[%s] value=[%s]",i+1,tostring(p),tostring(v)).."\n",Runner)
            if p then
              -- there is a name on next line
              if v then
                -- and a value
                if p == name then --Wbertro
                  Type = " -- List<>" -- ..Type..", p = "..p..", v = "..v
                else
                  -- there is a value on next line
                  -- Type = " -- Array[] / ENUM"
                  -- H.WriteToFileAppend(deltaX().."          : "..strformat("Type= [%s]",Type).."\n",Runner)
                end
              end
            elseif v then
              -- no name on next line, there is a value on next line
              -- if v == "X" then
                -- Type = " -- Vector"
              -- elseif v == "A" then
                -- Type = " -- Colour"
              -- else
                -- -- Type = " -- List<>"
              -- end
              -- H.WriteToFileAppend(deltaX().."          : "..strformat("Type= [%s]",Type).."\n",Runner)
            else
              -- no name and no value, should not happen
              Type = " -- ERROR"
              H.WriteToFileAppend(deltaX().."          : "..strformat("%d: Type= [%s]",i+1,Type).."\n",Runner)
            end
          end
        end
        
        level = level + 1

        STRUCT[#STRUCT+1] = posB..strrep(" ",level*structIndent)..result[2]..kwi..Type.."{"
        fileSTRUCTline[#fileSTRUCTline+1] = i
        fileSTRUCTlevel[#fileSTRUCTlevel+1] = level

        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
-- H.WriteToFileAppend(deltaX().."     DEBUG: "..strformat("Type = <%s>",Type).."\n",Runner)
        KEY_WORDS[#KEY_WORDS+1] = [["]]..result[2]..[[",]]..kwi..Type
        COMMENT[#COMMENT+1] = [[P..]]
        
      elseif strfind(text,[[ue=]],1,true) then
        -- just a Property value
        -- like: <Property value="TkProceduralTextureChosenOptionSampler.xml">
        level = level + 1
        
        STRUCT[#STRUCT+1] = posC..strrep(" ",level*structIndent)..result[3]..kwi.."{"
        fileSTRUCTline[#fileSTRUCTline+1] = i
        fileSTRUCTlevel[#fileSTRUCTlevel+1] = level

        if structLevel > 1 then
          numLinesToProcess_Skip = NMSstrings[strsub(result[3],1,-5)]
          -- if numLinesToProcess_Skip == nil then
            -- numLinesToProcess_Skip = 1 -- default
          -- end
          if numLinesToProcess_Skip then
            for n=1,numLinesToProcess_Skip do
              local _,_,val = table.unpack(FindKeywordsInLine(EXML[i+n],i+n))
              if val then
                STRUCT[#STRUCT] = STRUCT[#STRUCT].." ('"..val.."')"
              end
            end
            STRUCT[#STRUCT] = STRUCT[#STRUCT]:gsub("%) %(",",")
          end
        end
        
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = [["]]..result[3]..[[",]]..kwi
        COMMENT[#COMMENT+1] = [[P..]]
        
      elseif strfind(text,[[te=]],1,true) then
        --like: <Data template="GcExternalObjectList">
        --encountered only once at first line
        --NEVER a KEY_WORD

        STRUCT[#STRUCT+1] = " "..strrep(" ",level*structIndent)..strsub(H.StripInfo(text,[[te=]],[[>]]),2,-2).."{"
        fileSTRUCTline[#fileSTRUCTline+1] = i
        fileSTRUCTlevel[#fileSTRUCTlevel+1] = level

        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = H.StripInfo(text,[[te=]],[[>]]) --remembers template
        COMMENT[#COMMENT+1] = [[   ]]
        
      elseif strfind(text,[[</Data>]],1,true) then
        --like: </Data>
        --encountered only once at end of file
        --NEVER a KEY_WORD
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = "/Data }" --remembers "/Data"
        COMMENT[#COMMENT+1] = [[   ]]
        
      end
    end
    print(strformat("     ==> %u / %u",total,total))
    -- print(strformat(H._zUpOneLineErase.."     ==> %u / %u",total,total))
  end
-- H.WFAK("E")  
  
  if #EXML < count then 
    H.WriteToFileAppend(deltaX().."      DMFE: "..(#EXML-1).." lines processed\n",Runner)
  end
  
  H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: total lines processed = "..#EXML.."\n",Runner)

  local info = {}
  if H._mUSE_LUA_MAPFILETREE then
    local tUsing = "=== DisplayMapFileTreeEXT: using 'LUA"
    if H._mUSE_LUAPLUS_MAPFILETREE then
      tUsing = tUsing.."FULL"
    end
    -- H.WriteToFileAppend(deltaX()..tUsing.."' #"..#FILE_LINE..", "..#TREE_LEVEL..", "..#KEY_WORDS..", "..#COMMENT.."\n",Runner)
    
    --pre-process info to LUA format
    local previousLevel = -1
    -- local comment = ""
    for i=1,#KEY_WORDS do
      if (H._mUSE_LUAPLUS_MAPFILETREE and KEY_WORDS[i] == "<<< }") or (KEY_WORDS[i] ~= "<<< }") then
        local line = string.format("%8u",FILE_LINE[i])
        local level = string.format("%2u",TREE_LEVEL[i])
        local comment = COMMENT[i]
        
        local nLevel = tonumber(level)

        if H._mUSE_LUAPLUS_MAPFILETREE and KEY_WORDS[i] == "<<< }" then
          nLevel = nLevel - 1
        end
        
        if i > 1 then
          if nLevel < previousLevel then
            if H._mUSE_LUAPLUS_MAPFILETREE then
              --nothing to do
              --info[#info] = info[#info] --.." ".."}"
            else
              if KEY_WORDS[i] ~= "<<< }" or KEY_WORDS[i] ~= "/Data }" then
                -- info[#info] = info[#info].." "..string.rep("}",previousLevel - nLevel)
              -- else
                info[#info] = info[#info].." "..string.rep("}",previousLevel - nLevel)
              end
            end
          end
                
          if nLevel <= previousLevel then
            if not H._mUSE_LUAPLUS_MAPFILETREE and (string.sub(info[#info],1,3) == "{[P" and string.sub(comment,1,1) == "P") then
              info[#info] = info[#info].." }"
            end
          end
        end
        
        previousLevel = nLevel
        
        local tStart = ":"
        if not IsLanguageEXML and (string.sub(comment,1,1) == "P" or (i == 1)) then
          tStart = "{"
        end
        
        local INFO = tStart.."["..comment..":"..line..":"..level.."]"
        if comment == [[xxx]] then
          INFO = tStart.."[   plain test  ]"
        end

        if TREE_LEVEL[i] > 0 then
          if comment == [[xxx]] then
            info[#info+1] = INFO.."  "..string.rep("  ",TREE_LEVEL[i]-1)..KEY_WORDS[i]
          else          
            info[#info+1] = INFO.."- "..string.rep("- ",TREE_LEVEL[i]-1)..KEY_WORDS[i]
          end  
        else
          if i == 1 then
            info[#info+1] = INFO..string.rep("  ",TREE_LEVEL[i])..string.sub(KEY_WORDS[i],2,-2).." --Do not use, NOT a KEYWORD"
          elseif i == #KEY_WORDS then
            info[#info+1] = INFO..string.rep("  ",TREE_LEVEL[i])..KEY_WORDS[i].." --Do not use, NOT a KEYWORD"
          else
            info[#info+1] = INFO..string.rep("  ",TREE_LEVEL[i])..KEY_WORDS[i]
          end
        end
      end
    end
    -- H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: #info = "..#info.."\n",Runner)

  else --H._mUSE_TXT_MAPFILETREE  --nothing to pre-process
    local tUsing = "=== DisplayMapFileTreeEXT: using 'TXT"
    if H._mUSE_TXTPLUS_MAPFILETREE then
      tUsing = tUsing.."FULL"
    end
    -- H.WriteToFileAppend(deltaX()..tUsing.."' #"..#FILE_LINE..", "..#TREE_LEVEL..", "..#KEY_WORDS..", "..#COMMENT.."\n",Runner)
  end
  
  local waitingCount_1 = -1
  local waitingCount_2 = -1
  
  local filehandle = H.WriteToFileEXT(filepathname)
  if filehandle then
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: MapFileTree file 'opened' for ["..filepathname.."]\n",Runner)
    
    filehandle:write(">>> MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(H._mDateTimeFormat).."\n")
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique, 'V'alue, 'H'OES(possible HeadOfEmptySection)".."\n")    
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    

    if H._mUSE_LUA_MAPFILETREE then
      H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT:   processing 'LUA info' table\n",Runner)
      for i=1,#info do
        -- if i%count == 0 then 
          -- H.WriteToFileAppend(deltaX().."      INFO: "..i.." lines processed\n",Runner)
        -- end
        filehandle:write(info[i].."\n")
      end
      
    elseif H._mUSE_TXT_MAPFILETREE then
      H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT:   processing 'TXT KEY_WORDS' table\n",Runner)
      for i=1,#KEY_WORDS do
        -- if i%count == 0 then 
          -- H.WriteToFileAppend(deltaX().."      INFO: "..i.." lines processed\n",Runner)
        -- end
        if H._mUSE_TXTPLUS_MAPFILETREE or KEY_WORDS[i] ~= "<<< }" then
          local line = string.format("%8u",fileSTRUCTline[i])
          local level = string.format("%2u",TREE_LEVEL[i])
          
          local tKeywords = KEY_WORDS[i]
          if tKeywords == "<<< }" then
            tKeywords = string.sub(tKeywords,1,3)
          end
          
          local Info = ""
          if i == 1 then
            Info = "["..COMMENT[i]..":"..line..":"..level.."]"..string.rep("  ",TREE_LEVEL[i])..string.sub(tKeywords,2,-2).." --Do not use, NOT a KEYWORD"
          elseif i == #KEY_WORDS then
            Info = "["..COMMENT[i]..":"..line..":"..level.."]"..string.rep("  ",TREE_LEVEL[i])..string.sub(tKeywords,1,-2).." --Do not use, NOT a KEYWORD"
          else
            Info = "["..COMMENT[i]..":"..line..":"..level.."]"..string.rep("  ",TREE_LEVEL[i])..tKeywords
            if COMMENT[i] == [[xxx]] then
              Info = "[   plain test  ]"..string.rep("  ",TREE_LEVEL[i])..tKeywords
            end
         end
          filehandle:write(Info.."\n")
        end
      end
    end
    
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique, 'V'alue, 'H'OES(possible HeadOfEmptySection)".."\n")    
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write(">>> MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(H._mDateTimeFormat).."\n")
    
    filehandle:flush()
    filehandle:close()
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT:   output file 'closed'\n",Runner)

    -- H.sleep(1)
    repeat
      waitingCount_1 = waitingCount_1 + 1
      H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT:   'checking' ["..filepathname.."] existence...\n",Runner)
    until H.IsFileExist(filepathname) or waitingCount_1 > 10
    
    if #STRUCT > 0 then
      local fpn = fileStructPathname
      local filehandle = H.WriteToFileEXT(fpn)
      if filehandle then
        H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: STRUCTURE file 'opened' for ["..fpn.."]\n",Runner)
        filehandle:write(">>> FileStructure (Level "..structLevel.."): "..filename:gsub(".MXML",".struct").." ("..Pak_FileName..") "..os.date(H._mDateTimeFormat).."\n")

        for i=1,#STRUCT-1 do
          local line = "" -- string.format("%8u|",FILE_LINE[i])
          local level = "" -- string.format("%2u|",TREE_LEVEL[i])
          if IsLanguageEXML then
            filehandle:write(line..level..STRUCT[i].."\n")
          else
            filehandle:write(line..level..STRUCT[i]:gsub("}",""):gsub("{","").."\n") -- :gsub("}+","}")
          end
        end
        
        if IsLanguageEXML then
          filehandle:write(STRUCT[#STRUCT].."\n")
        else
          filehandle:write(STRUCT[#STRUCT]:gsub("}",""):gsub("{","").."\n\n")
        end
        filehandle:write(">>> FileStructure(Level "..structLevel.."): "..filename:gsub(".MXML",".struct").." ("..Pak_FileName..") "..os.date(H._mDateTimeFormat).."\n")
        
        filehandle:flush()
        filehandle:close()
        H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT:   output file 'closed'\n",Runner)

        repeat
          waitingCount_2 = waitingCount_2 + 1
          H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT:   'checking' ["..fpn.."] existence...\n",Runner)
        until H.IsFileExist(fpn) or waitingCount_2 > 10        
      end
    end

  else
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: 'COULD NOT OPEN output file: no filehandle'\n",Runner)
  end
  
  -- if waitingCount <= 10 then
    -- --file exist, ok to remove the copy in .\_TEMP_MAP
    -- local thisFile = gSourcePath..filename
    -- H.WriteToFileAppend(deltaX().."+++ Runner: Deleting file ["..thisFile.."]\n",Runner)
    -- os.remove(thisFile)
  -- end
  
  local returnMsg = "OK"
  if waitingCount_1 > 0 or waitingCount_2 > 0 then
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: ending with waitingCounts = "..waitingCount_1..", "..waitingCount_2.."\n",Runner)
    returnMsg = "UNKNOWN"
  else
    H.WriteToFileAppend(deltaX().."=== DisplayMapFileTreeEXT: ending with 'MapFileTree created!'\n",Runner)
  end
  return returnMsg
end

function RunnerThread()
  H.WriteToFileAppend(deltaX().."+++ In Runner...\n",Runner)
  local Count = 0
  local MaxCount = 240 -- seconds -- was 36 * 5 = 180
  local WaitTime = 1 -- was 5
  
  local OkToRun = false
  local FileListHandle = nil
  local Terminate = false
  
  while not OkToRun do
    FileListHandle = io.open([[MapFileTreeSharedList.txt]],"r")
    if FileListHandle == nil then
      H.WriteToFileAppend(deltaX().."+++ Runner: NOTICE >>> "..((MaxCount-Count+1)*WaitTime)..": Could not open MapFileTreeSharedList.txt.  Re-checking in "..WaitTime.." sec\n",Runner)
      H.sleep(WaitTime)
      
      if Count > MaxCount or (Count > 10 and not H.IsFileExist([[MapFileTreeCreatorRun.txt]])) then --failsafe exit
        Terminate = true
        H.WriteToFileAppend(deltaX().."+++ Runner: terminating on [waiting for MapFileTreeSharedList.txt]...\n",Runner)
        if H.IsFileExist([[MapFileTreeCreatorRun.txt]]) then
          H.WriteToFileAppend(deltaX().."+++ Runner: forcing removal of MapFileTreeCreatorRun.txt\n",Runner)
          os.remove([[MapFileTreeCreatorRun.txt]])
        end
        break
      end
      Count = Count + 1
    else
      H.WriteToFileAppend(deltaX().."+++ Runner: opened MapFileTreeSharedList.txt\n",Runner)
      OkToRun = true
    end
  end
  
  local List = {}
  local Done = {}
  local Recreate = {}

  if OkToRun then 
    H.WriteToFileAppend(deltaX().."+++ Runner: OkToRun\n",Runner)
  end

  local FlagError = false
  Count = 0 -- reset
  --normally to check 2 more times before quitting
  while OkToRun and not Terminate do
    -- H.WriteToFileAppend(deltaX().."+++ Runner: In while OkToRun and not Terminate do\n",Runner)
    local FileList = {}
    local line = FileListHandle:read("l")
    while line do 
      if line ~= " " then
        FileList[#FileList+1] = line
      end
      line = FileListHandle:read("l")
    end
    
    if FileList[#FileList] == "PING" then
      -- H.WriteToFileAppend(deltaX().."+++ Runner: Resetting exit timer on PING\n",Runner)
      --reset timer
      Count = 0 -- reset
    end
    
    -- H.WriteToFileAppend(deltaX().."+++ Runner: #FileList "..#FileList.."\n",Runner)
    -- H.WriteToFileAppend(deltaX().."+++ Runner: #List "..#List.."\n",Runner)
    -- H.WriteToFileAppend(deltaX().."+++ Runner: Updating 'List[] and Done[]'\n",Runner)
    local ListCount = #List
    for i=1,#FileList do
      --a new entry
      --add it to the list
      if not Done[i + ListCount] then
        local skipIt = false
        if FileList[i] ~= "PING" then
          for j=1,#List do
            if List[j] == FileList[i] then
              skipIt = true
            end
          end
        end
        
        if not skipIt then
          --report it
          --remove and count
          local file,num = string.gsub(FileList[i],".recreate","")
          local IsRecreate = (num > 0)
          if file ~= "PING" then
            H.WriteToFileAppend(deltaX().."+++ Runner: Adding "..(i + ListCount).." to List: ["..file.."]"..H.iif(IsRecreate," with Recreate","").."\n",Runner)
          end
          List[#List+1] = file
          Done[#Done+1] = false
          Recreate[#Recreate+1] = IsRecreate
        end
      end
    end
    
    local AllDone = true
    for i=1,#Done do
      if not Done[i] then
        AllDone = false
        break
      end
    end

    local returnMsg = ""
    if not AllDone then
      -- H.WriteToFileAppend(deltaX().."+++ Runner: #Done = "..#Done.."\n",Runner)
      for i=1,#Done do
        if List[i] == "PING" then
          Done[i] = true
        end
        
        if not Done[i] then
          -- H.WriteToFileAppend(deltaX().."+++ Runner: Resetting exit timer\n",Runner)
          Count = 0 -- reset
          H.WriteToFileAppend(deltaX().."+++ Runner: _____----_____\n",Runner)
          
          --process this file
          local thisFile = gSourcePath..List[i]
          H.WriteToFileAppend(deltaX().."+++ Runner: To parse file ["..thisFile.."]\n",Runner)
          
          --is this a LANGUAGE file?
          local IsLanguageEXML = false
          if string.sub(List[i],1,9) == [[LANGUAGE\]] then
            IsLanguageEXML = true
            H.WriteToFileAppend(deltaX().."+++ Runner: detected LANGUAGE file\n",Runner)
          end
          
          local IsFound = false
          local IsFoundCount = 0
          repeat
            IsFoundCount = IsFoundCount + 1
            -- H.WriteToFileAppend(deltaX().."+++ Runner:                'Checking' if it exist\n",Runner)
            IsFound = H.IsFileExist(thisFile)
            if IsFoundCount > 1 then
              H.sleep(1)
            end
          until IsFound or IsFoundCount > 30 --wait x sec to see if it will be available
          
          if IsFound then
            H.WriteToFileAppend(deltaX().."+++ Runner: file 'exist' in "..gSourcePath.."\n",Runner)
            -- H.sleep(10)
            local EXML = {}
            -- if not IsLanguageEXML then
              repeat
                EXML,msg = H.ParseTextFileIntoTable(thisFile)
                if string.sub(msg,1,5) == "ERROR" then
                  H.WriteToFileAppend(deltaX().."+++ Runner: H.ParseTextFileIntoTable() 'cannot process file yet'\n",Runner)
                  H.sleep(1)
                end
              until #EXML > 0
              -- H.WriteToFileAppend(deltaX().."+++ Runner: #EXML = "..#EXML.." \n",Runner)
            -- else
              -- --skipping loading it, no need to do it here AND in the SLAVE
              -- EXML = nil
            -- end

            if Recreate[i] then
              H.WriteToFileAppend(deltaX().."+++ Runner: 'delete old' mapfiletree\n",Runner)
              --we need to force remove 'old' copy
              local tmpMFT = [[..\TOOLS\MapFileTrees\]]..string.gsub(List[i],[[\]],[[.]])
              H.WriteToFileAppend(deltaX().."+++ Runner: tmpMFT = ["..tmpMFT.."]\n",Runner)
              if H.IsFileExist(tmpMFT..[[.lua]]) then
                os.execute([[Del /f /q /s "]]..tmpMFT..[[.lua" 1>NUL 2>NUL]])
                repeat
                  H.sleep(1)
                until not H.IsFileExist(tmpMFT..[[.lua]])
              elseif H.IsFileExist(tmpMFT..[[.txt]]) then
                os.execute([[Del /f /q /s "]]..tmpMFT..[[.txt" 1>NUL 2>NUL]])
                repeat
                  H.sleep(1)
                until not H.IsFileExist(tmpMFT..[[.txt]])
              end
            end
            
            -- ************************   PROCESS It   **************************
            returnMsg = DisplayMapFileTreeEXT(EXML,List[i],IsLanguageEXML)
            
            H.WriteToFileAppend(deltaX().."+++ Runner: DisplayMapFileTreeEXT exited with '"..returnMsg.."'\n",Runner)
            
            if returnMsg == "OK" or returnMsg == "UP_TO_DATE" then
              -- H.WriteToFileAppend(deltaX().."+++ Runner: Deleting file ["..thisFile.."]\n",Runner)
              -- os.remove(thisFile)
              Done[i] = true
            elseif returnMsg == "SKIP" then
              --wait for a free ProcessSlot
              Count = 0 -- reset
            end
          
          else
            --STILL NOT FOUND: mark it as Done
            H.WriteToFileAppend(deltaX().."+++ Runner: ["..thisFile.."] 'cannot be found'\n",Runner)
            Done[i] = true
          end --if IsFound then
        end --if not Done[i] then    
      end --for i=1,#Done do
      H.WriteToFileAppend(deltaX().."+++ Runner: finished Done[] list\n",Runner)
    end --if not AllDone then
    
    if returnMsg == "ERROR" then
      FlagError = true
    end
    
    --recheck
    AllDone = true
    for i=1,#Done do
      if not Done[i] then
        AllDone = false
        break
      end
    end
    
    if AllDone then
      if not H.IsFileExist([[MapFileTreeCreatorRun.txt]]) and Count > 1 then
        --terminate
        H.WriteToFileAppend(deltaX().."+++ Runner: received 'OK' to terminate...\n",Runner)
        H.WriteToFileAppend(deltaX().."+++ Runner: closing MapFileTreeSharedList.txt\n",Runner)
        FileListHandle:close()
        break
      -- elseif Count > 36 then
      elseif Count > MaxCount then
        H.WriteToFileAppend(deltaX().."+++ Runner: terminating on [Count]...\n",Runner)
        H.WriteToFileAppend(deltaX().."+++ Runner: closing MapFileTreeSharedList.txt\n",Runner)
        FileListHandle:close()
        H.WriteToFileAppend(deltaX().."+++ Runner: forcing removal of MapFileTreeCreatorRun.txt\n",Runner)
        os.remove([[MapFileTreeCreatorRun.txt]])
        break
      else
        if Count == 0 then
          H.WriteToFileAppend(deltaX().."+++ Runner: (PING) Exit in "..((MaxCount-Count)*WaitTime).." sec or less if no more jobs unless asked to terminate...\n",Runner)
        else
          H.WriteToFileAppend(deltaX().."+++ Runner: Exit in "..((MaxCount-Count)*WaitTime).." sec or less if no more jobs unless asked to terminate...\n",Runner)
        end
        Count = Count + 1

        local ProcessInfo = os.capture([[tasklist /FI "ImageName eq lua.exe"]])            

        if Count % 3 == 0 and not string.find(ProcessInfo,"lua.exe",1,true) then
          -- lua.exe is not running anymore, signal to terminate
          H.WriteToFileAppend(deltaX().."+++ Runner: terminating on [lua.exe stopped running]...\n",Runner)
          H.WriteToFileAppend(deltaX().."+++ Runner: closing MapFileTreeSharedList.txt\n",Runner)
          FileListHandle:close()
          H.WriteToFileAppend(deltaX().."+++ Runner: forcing removal of MapFileTreeCreatorRun.txt\n",Runner)
          os.remove([[MapFileTreeCreatorRun.txt]])
          break
        end
      end
    end

    -- H.WriteToFileAppend(deltaX().."+++ Runner: sleeping for "..WaitTime.." sec\n",Runner)
    H.sleep(WaitTime)
    
  end --while OkToRun and not Terminate do (will exit with break only)

  --NOT USED, every file handles this
  -- for i=1,#List do
    -- if List[i] ~= "PING" then
      -- local thisFile = gSourcePath..List[i]
      -- H.WriteToFileAppend(deltaX().."+++ Runner: Deleting file ["..thisFile.."]\n",Runner)
      -- os.remove(thisFile)
    -- end
  -- end

  if FlagError and H.IsFileExist([[..\WOPT_Wbertro.txt]]) then
    H.WriteToFileAppend(deltaX().."+++ Runner: WARNING >>> IN PAUSE MODE\n",Runner)
    -- /B /wait "" /MIN: order is important for it to work on win7 and early win10 version
    os.execute([[START /wait "In PAUSE MODE, see MapFileTreeRunner.lua" /MAX cmd /c PAUSE_MAPFILETREE.bat]])  
  end
  
  if H.IsFileExist([[MapFileTreeSharedList.txt]]) then
    H.WriteToFileAppend(deltaX().."+++ Runner: removing "..[[MapFileTreeSharedList.txt]].."\n",Runner)
    if not os.remove([[MapFileTreeSharedList.txt]]) then
      H.WriteToFileAppend(deltaX().."+++ Runner: NOTICE >>> MapFileTreeSharedList.txt 'already removed or locked'\n",Runner)
    end
  else
    H.WriteToFileAppend(deltaX().."+++ Runner: NOTICE >>> MapFileTreeSharedList.txt 'does not exist'!\n",Runner)
  end

  if H.IsFileExist([[MapFileTreeRequested.txt]]) then
    H.WriteToFileAppend(deltaX().."+++ Runner: removing "..[[MapFileTreeRequested.txt]].."\n",Runner)
    if not os.remove([[MapFileTreeRequested.txt]]) then
      H.WriteToFileAppend(deltaX().."+++ Runner: WARNING >>> 'could not remove' file MapFileTreeRequested.txt\n",Runner)
    end
  else
    H.WriteToFileAppend(deltaX().."+++ Runner: WARNING >>> MapFileTreeRequested.txt 'does not exist'!\n",Runner)
  end
  
  --NOT USED: SLAVES still need it
  -- local folder = string.sub(gSourcePath,1,#gSourcePath-1)
  -- H.WriteToFileAppend(deltaX().."+++ Runner: Deleting ["..folder.."]\n",Runner)
  -- os.execute([[START /wait "" /B /MIN cmd /c Clean_TEMP_MAP.bat]])
  
  H.WriteToFileAppend(deltaX().."+++ Runner: terminated\n",Runner)

end

-- ****************************************************
--                        main
-- ****************************************************

--we are in MODBUILDER

--to prevent LuaStarting() when loading LoadHelpers.lua
local FlagLua = true
if H == nil then dofile("LoadHelpers.lua") end
-- H.pv(">>>     In CreateMapFileTree.lua")
H.gfilePATH = "..\\" --for Report()

-- H._zUpOneLineErase="[F[K"

THIS = "In CreateMapFileTree: "

-- H._mLUA = os.getenv("_mLUA")
-- H._mLUAS = os.getenv("_mLUAS")

gX = os.clock()

--default
H._mDateTimeFormat = "%Y/%m/%d-%H:%M:%S"
H.CustomDateTimeFormat = false

if H.IsFileExist([[..\CONFIG\DateTimeFormat.txt]]) then
  local tmpDTF = H.LoadFileData([[..\CONFIG\DateTimeFormat.txt]])
  if tmpDTF and tmpDTF ~= H._mDateTimeFormat then
    H._mDateTimeFormat = tmpDTF
    H.CustomDateTimeFormat = true
  end
end

NMS_FOLDER = H.LoadFileData([[..\CONFIG\NMS_FOLDER.txt]])
NMS_FOLDER = string.sub(NMS_FOLDER,1,string.find(NMS_FOLDER,"Sky",1,true)+2)
NMS_PCBANKS_FOLDER_PATH = NMS_FOLDER..[[\GAMEDATA\PCBANKS\]]

--not used
--gMASTER_FOLDER_PATH = H.LoadFileData("MASTER_FOLDER_PATH.txt")
--gMASTER_FOLDER_PATH = string.gsub(lfs.currentdir(),[[MODBUILDER]],"")
LocalFolder = [[MODBUILDER\]]

H._mUSE_TXT_MAPFILETREE = H.IsFileExist([[USE_TXT_MAPFILETREE.txt]])
print("_mUSE_TXT_MAPFILETREE == "..tostring(H._mUSE_TXT_MAPFILETREE))
H._mUSE_LUA_MAPFILETREE = H.IsFileExist([[USE_LUA_MAPFILETREE.txt]])
print("_mUSE_LUA_MAPFILETREE == "..tostring(H._mUSE_LUA_MAPFILETREE))

if not H._mUSE_TXT_MAPFILETREE then
  H._mUSE_LUA_MAPFILETREE = true --default
end

H._mUSE_TXTPLUS_MAPFILETREE = H.IsFileExist([[USE_TXTPLUS_MAPFILETREE.txt]])
print("_mUSE_TXTPLUS_MAPFILETREE == "..tostring(H._mUSE_TXTPLUS_MAPFILETREE))
H._mUSE_LUAPLUS_MAPFILETREE = H.IsFileExist([[USE_LUAPLUS_MAPFILETREE.txt]])
print("_mUSE_LUAPLUS_MAPFILETREE == "..tostring(H._mUSE_LUAPLUS_MAPFILETREE))

Runner = "MapFileTreeRunner.lua"
-- gSourcePath = [[.\_TEMP_MAP\]]
gSourcePath = [[.\_TEMP\DECOMPILED\]]

-- H.gpak_listTable = H.ParseTextFileIntoTable("pak_list.txt")

LWriteToFileAppendEXT = H.WriteToFileAppend

function H.WriteToFileAppend(msg,filename)
  if filename == Runner then
    --send to both cmd window and Runner file
    LWriteToFileAppendEXT(msg,filename)
    local msg = string.gsub(msg,"\n","") --remove line break if any
    print(msg)
  else
    LWriteToFileAppendEXT(msg,filename)
  end
end

function deltaX()
  return string.format("%7.3f",os.clock()-gX).." "
end

--os.remove(Runner)

tmp = "TXT"
if H._mUSE_LUA_MAPFILETREE then
  tmp = "LUA"
end

tmp2 = ""
if H._mUSE_TXTPLUS_MAPFILETREE or H._mUSE_LUAPLUS_MAPFILETREE then
  tmp2 = "FULL"
end

-- get ENUM info
local libMBIN_Content = [[..\TOOLS\NMSPE_Output\libMBIN_Content\Content_libMBIN_v]]..H.LoadFileData("MBINCompilerCurrentVersion.txt"):gsub("\n","")..[[.lua]]
-- H.printf("libMBIN_Content = [%s]",libMBIN_Content)

enumsK = {} -- also prevents duplicates

if H.IsFileExist(libMBIN_Content) then
  local content = H.ParseTextFileIntoTable(libMBIN_Content)
  -- H.printf("#content = %d",#content)
  print()
  
  -- local enumsI = {}
  for i=1,#content do
    local enum = string.match(content[i],"(.-)Enum =")
    -- local parent = string.match(content[i],"(.-) =")
    if enum and enumsK[enum] == nil then
      -- enumsI[#enumsI+1] = enum
      enumsK[enum] = true
    end
  end
  
  -- local function sortENUM(a,b)
    -- return a:upper() < b:upper()
  -- end
  
  -- table.sort(enumsI,sortENUM)

  -- for i=1,#enumsI do
    -- H.printf("%s",enumsI[i])    
  -- end
  
  -- H.printf("#enumsI = %d",#enumsI)
end
-- H.WFAK()


gNumCores = tonumber(os.getenv("NUMBER_OF_PROCESSORS"))
local ProcessInfo = os.capture([[tasklist /FI "ImageName eq lua.exe"]])            

--main and this instance
_,gNumCoresBase = string.gsub(ProcessInfo,"lua.exe","")

gUseNumCores = gNumCores - gNumCoresBase - 4 --leave 2 free
if gUseNumCores <= 0 then
  gUseNumCores = gNumCores - 2
  if gUseNumCores <= 0 then
    gUseNumCores = 0
  end
end

-- --prepare in use process counter
-- gUsedProcessFile = "UsedProcess.lua"
-- H.WriteToFile("\n",gUsedProcessFile)

H.WriteToFileAppend(deltaX().."+++ "..os.date(H._mDateTimeFormat).."\n",Runner)
H.WriteToFileAppend(deltaX().."+++ Starting 2nd thread: '"..tmp..tmp2.."'\n",Runner)
H.WriteToFileAppend(deltaX().."+++ Runner: 'v"..H.LoadFileData("AMUMSSVersion.txt").."'\n",Runner)
H.WriteToFileAppend(deltaX().."+++ Runner: gUseNumCores = "..gUseNumCores.."\n",Runner)
print()
print([[  PLEASE DO NOT CLOSE THIS WINDOW, IT WILL SELF-CLOSE WHEN ITS WORK IS DONE!]])
print()
--H.sleep(20) --let OS catch up...
-- H.WFAK("CreateMapFileTree START...")
RunnerThread()
-- H.WFAK("CreateMapFileTree END...")
-- H.pv(THIS.."ending")
-- H.LuaEndedOk(THIS)
