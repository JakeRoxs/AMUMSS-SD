function CreateMapFileTreeEXT(filename,MainFolders)
  local string = string
    local strsub = string.sub
    local strgsub = string.gsub
    local strfind = string.find
    local strlen = string.len -- much better to use #, if you can
    local strupper = string.upper
    local strrep = string.rep
    local strformat = string.format
  local print = print
  local tostring = tostring
  local tonumber = tonumber
  local type = type
  local table = table
  local math = math
  local os = os

-- print("CreateMapFileTreeEXT current dir = "..lfs.currentdir())
-- print()

  local WholeTextFile = H.LoadFileData(gSourcePath..filename) --the EXML file as one string, for speed searching for uniqueness
  local EXML = WholeTextFile:splitB("\n")
-- print("#EXML = "..tostring(#EXML).." lines")
-- print("    filename = "..tostring(filename))
  
  --terminate if problem getting the file
  if type(EXML) ~= "table" then
    return "ERROR" --abandon effort to create
  end
  if #EXML <= 1 then
    return "ERROR" --abandon effort to create
  end

  -- extract relative file path
  local extraPath = ""
  for i=1,#MainFolders do
    local pos = strfind(filename,[[\]]..MainFolders[i],1,true)
    if pos then
      extraPath = strsub(filename,1,pos - 1)..[[\]]
      break
    end
  end
  if extraPath == "" then
    -- could be a global
    filename = H.GetFilenameFromFilePath(filename)
  else
    filename = strsub(filename,#extraPath + 1)
  end
-- print("NMS filename = "..tostring(filename))
-- print()
  
  local KEY_WORDS = {}
  local TREE_LEVEL = {}
  local FILE_LINE = {}
  local COMMENT = {}
  local level = 0
  
  local Pak_FileName = H.LocatePAK(filename)
  
  local fileInfo = strgsub(filename,[[\]],[[.]])
  local filepathname = [[..\TOOLS\MapFileTrees\]]..fileInfo
  
  if H._mUSE_TXT_MAPFILETREE then
    filepathname = filepathname..".txt"
  else --use default
    H._mUSE_LUA_MAPFILETREE = true
    filepathname = filepathname..".lua"
  end
-- print("filepathname = "..tostring(filepathname))

  --***************************************************************************************************  
  local function FindKeywordsInLine(text,i)
      local value = H.StripInfo(text,[[ue="]],[["]])
      local name = H.StripInfo(text,[[me="]],[["]])
      return {strformat("%8u",i),name,value}
  end
  --***************************************************************************************************  

  --***************************************************************************************************
  --EXML = table of the file
  --j = where to start in the table
  --returns kwType, a table
  local function FastEXML_UNIQUEtable(EXML,j)
    local kwType = {}
    for i = j+1, #EXML-1 do
      local line = strupper(H.ltrim(EXML[i])) -- to make it case-insensitive
      -- if strsub(line,1,2) ~= "</" then
        -- not a <\Property>
        if strfind(line,"ME=",1,true) then
          if kwType[line] == nil then
            kwType[line] = "SU" -- Special and Unique
          elseif kwType[line] == "SU" then
            kwType[line] = "S" -- Special, not unique
          end
        end
      -- end
    end
    return kwType
  end
  --***************************************************************************************************
  
  dofile("NMSstrings.lua")
  
  local count = 10000
  
  --skipping a few lines at start
  local j = 0
  repeat
    j = j + 1
    if EXML[j] == nil then break end
  until strfind(EXML[j],[[te=]],1,true)
  
-- local time = os.clock()
  -- pre-process the exml for SPECIAL UNIQUE
  local kwType = FastEXML_UNIQUEtable(EXML,j)
-- local elapsed = os.clock()-time
-- print("")
-- print(tostring(elapsed).." pre-process")
-- print(strformat("sec/1000 lines = %f",(elapsed/#EXML)*1000))
  
  local IsLanguageEXML = false
  if strfind(EXML[j],"TkLocalisationTable",1,true) then
    IsLanguageEXML = true
  end
  
  if IsLanguageEXML then
    -- print("\n     ==> LANGUAGE file, BE PATIENT...")
    local function WTFA(...)
      -- --H.WriteToFileAppend(...)
      print(...)
    end

    local Language = ""
    local value = ""
    
    local startOfSection = j + 2
    local ValueLineOffsetInSection = 0
    local IdLineOffsetInSection = 1
    
    local sectionSize = startOfSection
    local s = EXML[startOfSection]
    local foundLanguage = false
    
    for i=startOfSection+1,#EXML do
      --get size of TkLocalisationEntry.xml section
      if s == EXML[i] then
        sectionSize = i - sectionSize
        break
      end
      --look ahead for the 'not empty' language value
      -- if not foundLanguage and strfind(EXML[i],[[me="Value"]],1,true) then
      if not foundLanguage and not strfind(strupper(EXML[i]),[[ NAME="ID"]],1,true) and not strfind(EXML[i],[[ value=""]],1,true) then
        -- if H.StripInfo(EXML[i],[[ue="]],[[" />]]) ~= [[]] then
          --found a non-empty value
          ValueLineOffsetInSection = i - startOfSection
          value = H.StripInfo(EXML[i],[[ue="]],[[" />]])
          --previous line is the language for this LANGUAGE file
          Language = H.StripInfo(EXML[i],[[me="]],[[" value=]])
          foundLanguage = true
        -- end
      end
    end
    
    -- WTFA(deltaX().."      DMFE: LANGUAGE is <"..Language..">")
    -- WTFA(deltaX().."      DMFE: section Size = ["..sectionSize.."]")
    -- WTFA(deltaX().."      DMFE: start of 1st section at ["..startOfSection.."]")
    -- WTFA(deltaX().."      DMFE: 'Id' found at OFFSET ["..IdLineOffsetInSection.."]")
    -- WTFA(deltaX().."      DMFE: 'value=' found at OFFSET ["..ValueLineOffsetInSection.."] ["..value.."]")
    
    --[[ looks like
    <Data template="TkLocalisationTable"> -- j
      <Property name="Table"> -- j + 1
      
        <Property value="TkLocalisationEntry.xml"> -- startOfSection
          <Property name="Id" value="UPDATE6_TITLE" /> -- startOfSection + IdLineOffsetInSection
          <Property name="USEnglish" value="VariableSizeString.xml"> -- startOfSection + ValueLineOffsetInSection - 1
            <Property name="Value" value="No Man's Sky Origins Update" /> -- startOfSection + ValueLineOffsetInSection
          </Property> -- startOfSection + sectionSize - 2
        </Property> -- startOfSection + sectionSize - 1
        
      </Property> -- #EXML - 1
    </Data> --#EXML
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
    local startCount = count -- * 10
    local total = #EXML-3

    print("")
    print("     ==> Working...")
    for i=startOfSection, total, sectionSize do
      if i > startCount then 
        startCount = startCount + count -- (count * 10)
        print(strformat(H._zUpOneLineErase.."     ==> %u / %u",i,total))
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
      local Name = ""
      if strfind(text,[[me=]],1,true) and strfind(text,[[ue=]],1,true) then
        Name = H.StripInfo(text,[[me="]],[[" value=]])
      end
      
      if Name ~= "" then
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
            if kwType[strupper(H.ltrim(text))] == "SU" then
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

          KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..value..[[",},]] --remembers name and value
          COMMENT[#COMMENT+1] = UniqueMsg

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
      level = level + 1
      FILE_LINE[#FILE_LINE+1] = offsetLine + 1
      TREE_LEVEL[#TREE_LEVEL+1] = level

      local result = FindKeywordsInLine(EXML[offsetLine + 1],offsetLine + 1)
      KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..result[3]..[[",},]] --remembers name and value
      COMMENT[#COMMENT+1] = [[.SU]]

      -- add plain text value
      FILE_LINE[#FILE_LINE+1] = offsetLine + 1
      TREE_LEVEL[#TREE_LEVEL+1] = level
      KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..H.CharEntitiesReverse(result[3])..[[",},]] --remembers name and value
      COMMENT[#COMMENT+1] = [[xxx]]

      -- WTFA(deltaX().."      DMFE: G["..EXML[i + sectionSize - 2].."]\n",Runner)
      --<<<
      -- table.insert(FILE_LINE,i + sectionSize - 2)
      -- table.insert(TREE_LEVEL,level)
      -- table.insert(KEY_WORDS, "<<< }") --remembers end of section
      -- table.insert(COMMENT, [[   ]])
      level = level - 1

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

    print(strformat(H._zUpOneLineErase.."     ==> %u / %u",total,total))

-- print(" #FILE_LINE = [ "..#FILE_LINE.."]")
-- print("#TREE_LEVEL = [ "..#TREE_LEVEL.."]")
-- print(" #KEY_WORDS = [ "..#KEY_WORDS.."]")
-- print("   #COMMENT = [ "..#COMMENT.."]")

-- local elapsed = os.clock()-time
-- print(tostring(elapsed).." END")
-- print(strformat("sec/1000 lines = %f",(elapsed/total)*1000))
-- H.WFAK()

  else --all other EXML files
    print("")
    print("     ==> Working...")
    local total = #EXML
    for i=j,total do
      if i%count == 0 then 
        print(strformat(H._zUpOneLineErase.."     ==> %u / %u",i,total))
      end

      local text = EXML[i]
      local result = FindKeywordsInLine(text,i)
      
      if strfind(text,[[/>]],1,true) then
        --ALL lines with "/>"
        local Name = ""
        if strfind(text,[[me=]],1,true) and strfind(text,[[ue=]],1,true) then
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
            if value ~= "" then
              UniqueMsg = [[.S.]]
              if kwType[strupper(H.ltrim(text))] == "SU" then
                UniqueMsg = [[.SU]]
                if value == [[True]] or value == [[False]] or tonumber(value) then
                  UniqueMsg = [[.su]]
                end
              
              elseif value == [[True]] or value == [[False]] or tonumber(value) then
                UniqueMsg = [[.s.]]
              end
            end
            
            KEY_WORDS[#KEY_WORDS+1] = [[{"]]..result[2]..[[","]]..value..[[",},]] --remembers name and value
            COMMENT[#COMMENT+1] = UniqueMsg
          else
            --like: <Property name="Seed" value="0" />
            --level = level + 1
            FILE_LINE[#FILE_LINE+1] = i
            TREE_LEVEL[#TREE_LEVEL+1] = level + 1
            KEY_WORDS[#KEY_WORDS+1] = [["]]..result[3]..[["]]
            COMMENT[#COMMENT+1] = [[   ]]
          end
        else
          --like: <Property value="3" /> or <Property name="VROverrides" />
          --level = level + 1
          FILE_LINE[#FILE_LINE+1] = i
          TREE_LEVEL[#TREE_LEVEL+1] = level + 1
          KEY_WORDS[#KEY_WORDS+1] = H.StripInfo(text,[[=]],[[ />]])

          if strfind(text,[[ue=]],1,true) then
            --like: <Property value="3" />
            COMMENT[#COMMENT+1] = [[V..]]
          else
            --like: <Property name="VROverrides" />
            -- could be a HOES (Head Of Empty Section)
            COMMENT[#COMMENT+1] = [[H..]]
            KEY_WORDS[#KEY_WORDS] = KEY_WORDS[#KEY_WORDS].." -- List<>"  
          end
        end
        
      -- from here on, no lines with "/>".  Only lines with ">"
      elseif strfind(text,[[</Property>]],1,true) then
        --like: </Property>
        --NEVER a KEY_WORD but should remove preceding KEY_WORD
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = "<<< }" --remembers end of section
        COMMENT[#COMMENT+1] = [[   ]]
        level = level - 1
        
      elseif strfind(text,[[me=]],1,true) and strfind(text,[[ue=]],1,true) then
        --like: <Property name="ProceduralTexture" value="TkProceduralTextureChosenOptionList.xml">        
        level = level + 1
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        
        local name = H.StripInfo(text,[[me=]],[[ value=]]) --remembers name
        local specialName = ""
        
        --this could also be a SPECIALNAME
        --like: <Property name="Rarity" value="GcRarity.xml">
        local value = result[3] -- H.StripInfo(text,[[value="]],[["]])
        local UniqueMsg = [[PS.]]
        if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil then
          if kwType[strupper(H.ltrim(text))] == "SU" then
            UniqueMsg = [[PSU]]
            if value == "True" or value == "False" or tonumber(value) then
              UniqueMsg = [[Psu]]
            end
          end
          specialName = [[ / {]]..name..[[,"]]..value..[[",},]]
        elseif value == "True" or value == "False" or tonumber(value) then
          UniqueMsg = [[Ps.]]
        end

        KEY_WORDS[#KEY_WORDS+1] = name..","..specialName
        
        if specialName ~= "" then
          COMMENT[#COMMENT+1] = UniqueMsg
        else
          COMMENT[#COMMENT+1] = [[   ]]
        end
        
      elseif strfind(text,[[me=]],1,true) then
        --here there is NO value
        --like: <Property name="Landmarks">

        --   could be a List<> or Array/Enum
        local Type = ""
        if i < total then
          -- H.WriteToFileAppend(deltaX().."     DEBUG: "..strformat("%d: %s",i,EXML[i]).."\n",Runner)
          --   looking ahead:
          local p,v = H.GetPropertyNameValue(EXML[i + 1])
          -- H.WriteToFileAppend(deltaX().."          : "..strformat("%d: name=[%s] value=[%s]",i+1,tostring(p),tostring(v)).."\n",Runner)
          if p then
            -- there is a name on next line
            if v then
              -- there is a value on next line
              Type = " -- Array[] / ENUM"
              -- H.WriteToFileAppend(deltaX().."          : "..strformat("Type= [%s]",Type).."\n",Runner)
            end
          elseif v then
            -- no name, there is a value on next line
            Type = " -- List<>"
            -- H.WriteToFileAppend(deltaX().."          : "..strformat("Type= [%s]",Type).."\n",Runner)
          else
            -- no name and no value, should not happen
            Type = " -- ERROR"
            H.WriteToFileAppend(deltaX().."          : "..strformat("%d: Type= [%s]",i+1,Type).."\n",Runner)
          end
        end
        
        level = level + 1
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = [["]]..result[2]..[[",]]..Type
        COMMENT[#COMMENT+1] = [[P..]]
        
      elseif strfind(text,[[ue=]],1,true) then
        --like: <Property value="TkProceduralTextureChosenOptionSampler.xml">
        level = level + 1
        FILE_LINE[#FILE_LINE+1] = i
        TREE_LEVEL[#TREE_LEVEL+1] = level
        KEY_WORDS[#KEY_WORDS+1] = [["]]..result[3]..[[",]]
        COMMENT[#COMMENT+1] = [[P..]]
        
      elseif strfind(text,[[te=]],1,true) then
        --like: <Data template="GcExternalObjectList">
        --encountered only once at first line
        --NEVER a KEY_WORD
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
    print(strformat(H._zUpOneLineErase.."     ==> %u / %u",total,total))
  end
  
-- print("#FILE_LINE = "..tostring(#FILE_LINE))

  local info = {}
  if H._mUSE_LUA_MAPFILETREE then
    local tUsing = "=== DisplayMapFileTreeEXT: using 'LUA"
    if H._mUSE_LUAPLUS_MAPFILETREE then
      tUsing = tUsing.."FULL"
    end
    
    --pre-process info to LUA format
    local previousLevel = -1
    -- local comment = ""
    for i=1,#KEY_WORDS do
      if (H._mUSE_LUAPLUS_MAPFILETREE and KEY_WORDS[i] == "<<< }") or (KEY_WORDS[i] ~= "<<< }") then
        local line = strformat("%8u",FILE_LINE[i])
        local level = strformat("%2u",TREE_LEVEL[i])
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
                -- info[#info] = info[#info].." "..strrep("}",previousLevel - nLevel)
              -- else
                info[#info] = info[#info].." "..strrep("}",previousLevel - nLevel)
              end
            end
          end
                
          if nLevel <= previousLevel then
            if not H._mUSE_LUAPLUS_MAPFILETREE and (strsub(info[#info],1,3) == "{[P" and strsub(comment,1,1) == "P") then
              info[#info] = info[#info].." }"
            end
          end
        end
        
        previousLevel = nLevel
        
        local tStart = ":"
        if not IsLanguageEXML and (strsub(comment,1,1) == "P" or (i == 1)) then
          tStart = "{"
        end
        
        local INFO = tStart.."["..comment..":"..line..":"..level.."]"
        if comment == [[xxx]] then
          INFO = tStart.."[   plain test  ]"
        end

        if TREE_LEVEL[i] > 0 then
            info[#info+1] = INFO.."- "..strrep("- ",TREE_LEVEL[i]-1)..KEY_WORDS[i]
        else
          if i == 1 then
            info[#info+1] = INFO..strrep("  ",TREE_LEVEL[i])..strsub(KEY_WORDS[i],2,-2).." --Do not use, NOT a KEYWORD"
          elseif i == #KEY_WORDS then
            info[#info+1] = INFO..strrep("  ",TREE_LEVEL[i])..KEY_WORDS[i].." --Do not use, NOT a KEYWORD"
          else
            info[#info+1] = INFO..strrep("  ",TREE_LEVEL[i])..KEY_WORDS[i]
          end
        end
      end
    end

  else --H._mUSE_TXT_MAPFILETREE  --nothing to pre-process
    local tUsing = "=== DisplayMapFileTreeEXT: using 'TXT"
    if H._mUSE_TXTPLUS_MAPFILETREE then
      tUsing = tUsing.."FULL"
    end
  end

  local filehandle = H.WriteToFileEXT(filepathname)
  if filehandle then
    filehandle:write(">>> MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(H._mDateTimeFormat).."\n")
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique, 'V'alue, 'H'OES(possible HeadOfEmptySection)".."\n")    
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    

    if H._mUSE_LUA_MAPFILETREE then
      for i=1,#info do
        filehandle:write(info[i].."\n")
      end
      
    elseif H._mUSE_TXT_MAPFILETREE then
      for i=1,#KEY_WORDS do
        if H._mUSE_TXTPLUS_MAPFILETREE or KEY_WORDS[i] ~= "<<< }" then
          local line = strformat("%8u",FILE_LINE[i])
          local level = strformat("%2u",TREE_LEVEL[i])
          
          local tKeywords = KEY_WORDS[i]
          if tKeywords == "<<< }" then
            tKeywords = strsub(tKeywords,1,3)
          end
          
          local info = ""
          if i == 1 then
            info = "["..COMMENT[i]..":"..line..":"..level.."]"..strrep("  ",TREE_LEVEL[i])..strsub(tKeywords,2,-2).." --Do not use, NOT a KEYWORD"
          elseif i == #KEY_WORDS then
            info = "["..COMMENT[i]..":"..line..":"..level.."]"..strrep("  ",TREE_LEVEL[i])..strsub(tKeywords,1,-2).." --Do not use, NOT a KEYWORD"
          else
            info = "["..COMMENT[i]..":"..line..":"..level.."]"..strrep("  ",TREE_LEVEL[i])..tKeywords
            if COMMENT[i] == [[xxx]] then
              Info = "[   plain test  ]"..string.rep("  ",TREE_LEVEL[i])..tKeywords
            end
          end
          filehandle:write(info.."\n")
        end
      end
    end
    
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique, 'V'alue, 'H'OES(possible HeadOfEmptySection)".."\n")    
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write(">>> MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(H._mDateTimeFormat).."\n")
    
    filehandle:flush()
    filehandle:close()

  end
  
  return "'"..filepathname.."' >>> OK"
end

-- ****************************************************
-- main (above should be like SCRIPTBUILDER\TestReCreatedScript.lua)
--      (below not at all)
-- ****************************************************

--we are in MODBUILDER

--to prevent LuaStarting() when loading LoadHelpers.lua
local FlagLua = true
if H == nil then dofile("LoadHelpers.lua") end
H.gfilePATH = "..\\" --for Report()

-- H._zUpOneLineErase="[F[K"

THIS = "In CreateSlaveMapFileTree: "
SLAVE = true

function deltaX()
  return string.format("%7.3f",os.clock()-gX).." "
end

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

gX = os.clock()

NMS_FOLDER = H.LoadFileData([[..\CONFIG\NMS_FOLDER.txt]])
NMS_FOLDER = string.sub(NMS_FOLDER,1,string.find(NMS_FOLDER,"Sky",1,true)+2)
NMS_PCBANKS_FOLDER_PATH = NMS_FOLDER..[[\GAMEDATA\PCBANKS\]]

LocalFolder = [[MODBUILDER\]]

H._mUSE_TXT_MAPFILETREE = H.IsFileExist([[USE_TXT_MAPFILETREE.txt]])
H._mUSE_LUA_MAPFILETREE = H.IsFileExist([[USE_LUA_MAPFILETREE.txt]])

if not H._mUSE_TXT_MAPFILETREE then
  H._mUSE_LUA_MAPFILETREE = true --default
end

H._mUSE_TXTPLUS_MAPFILETREE = H.IsFileExist([[USE_TXTPLUS_MAPFILETREE.txt]])
H._mUSE_LUAPLUS_MAPFILETREE = H.IsFileExist([[USE_LUAPLUS_MAPFILETREE.txt]])

gSourcePath = [[]]

-- H.gpak_listTable = H.ParseTextFileIntoTable("pak_list.txt")

tmp = "TXT"
if H._mUSE_LUA_MAPFILETREE then
  tmp = "LUA"
end

tmp2 = ""
if H._mUSE_TXTPLUS_MAPFILETREE or H._mUSE_LUAPLUS_MAPFILETREE then
  tmp2 = "FULL"
end

local MainFolders = H.ParseTextFileIntoTable("NMSMainFolders.txt")
if #MainFolders > 0 then
  local msg = CreateMapFileTreeEXT(arg[1],MainFolders)

  print("            Done: "..msg)
  print()
else
  -- this should not happen, handled by calling app console
  print("MISSING MainFolders List!")
end

-- H.WFAK("CreateMapFileTree_console...")
