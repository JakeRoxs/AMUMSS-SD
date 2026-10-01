
-- THIS script creates/updates ModScript\ModHelperScripts\DICTIONARY.lua file

-- USER choices area:

-- Uncomment the one LANGUAGE you want to have Dictionaries for:
--   if many are uncommented, the LAST ONE wins
-- local Language = "BRAZILIANPORTUGUESE"
-- local Language = "DUTCH"
local Language = "ENGLISH"
-- local Language = "FRENCH"
-- local Language = "GERMAN"
-- local Language = "ITALIAN"
-- local Language = "JAPANESE"
-- local Language = "KOREAN"
-- local Language = "LATINAMERICANSPANISH"
-- local Language = "POLISH"
-- local Language = "PORTUGUESE"
-- local Language = "RUSSIAN"
-- local Language = "SIMPLIFIEDCHINESE"
-- local Language = "SPANISH"
-- local Language = "TENCENTCHINESE"
-- local Language = "TRADITIONALCHINESE"
-- local Language = "USENGLISH"

-- Include Descriptions in Dictionary
local IncludeDescriptions = false

--***************************************************************************************************
-- END of USER choices area
--***************************************************************************************************

-- STOP STOP STOP STOP
--    ==>> DO NOT change anything below this line

--***************************************************************************************************
-- function GetPropertyNameValue(line)
-- line = a line from the EXML
-- returns: in ORIGINAL CASE
--   p, v    for 'Property name=', 'value='
--   p, nil  for 'Property name=', nil
--   nil, v  for nil, 'Property value='
--   nil, nil if not found
function GetPropertyNameValue(line)
  local pattern = [["(.-)".+"(.-)"]]
  local strmatch = string.match
  -- p = Property name/value
  -- v = value
  local p,v = strmatch(line,pattern)
  if p and v then
    -- found Property name= AND value=
    return p,v
  else
    pattern = [["(.-)"]]
    local p = strmatch(line,pattern)
    
    if p then
      if string.find(line,"me=",1,true) then
        -- Property name/value= only
        return p,nil
      else
        -- value= only
        return nil,p
      end
    end
  end 
  return nil,nil
end
--***************************************************************************************************

--***************************************************************************************************
-- from lMonk#7949: neat little code for LANGUAGE files
-- https://discord.com/channels/215514623384748034/215514674869829633/1088554918056562799
function CharEntitiesReverse(s)
  local entity = {
    {'&', '&amp;'}, -- must be first
    {'<', '&lt;'},
    {'>', '&gt;'},
    {'"', '&quot;'},
    {'|NL|','&#xA;'},
    {'|NL|','&#10;'}
  }
  if not s then
    return ""
  end
  for _,e in ipairs(entity) do
    s = s:gsub(e[2], e[1])
  end
  return s
end
--***************************************************************************************************

--***************************************************************************************************  
-- EXML: a table of the MXML language file group
local function GetId_String(EXML)
  local Id_string = {}
  -- skipping a few lines at start
  local j = 0
  repeat
    j = j + 1
    if EXML[j] == nil then break end
  until string.find(string.upper(EXML[j]),[[ NAME="ID"]],1,true)

  if EXML[j] == nil then
    return Id_string
  end

  local startOfSection = j - 1
  local ValueLineOffsetInSection = 0
  local IdLineOffsetInSection = 1
  
  local sectionSize = startOfSection -- for now
  local IsFoundLanguage = false
  
  for i = startOfSection + 1, #EXML do
    -- get size of TkLocalisationEntry section
    if string.find(EXML[i],"</P",1,true) then
      -- found END of SECTION
      sectionSize = i - sectionSize + 1
      break
    end
    --look ahead for the 'not empty' language value
    if not IsFoundLanguage and not string.find(string.upper(EXML[i]),[[ NAME="ID"]],1,true) and not string.find(EXML[i],[[ value=""]],1,true) then
      --found a non-empty value
      ValueLineOffsetInSection = i - startOfSection
      IsFoundLanguage = true
    end
  end
  
  -- H.printf("startOfSection = %d",startOfSection)
  -- H.printf("sectionSize = %d",sectionSize)
  -- H.printf("IdLineOffsetInSection = %d",IdLineOffsetInSection)
  -- H.printf("ValueLineOffsetInSection = %d",ValueLineOffsetInSection)
  -- H.printf("#EXML - 3 = %d",#EXML - 3)

  -- local count = 0
  for i=startOfSection, #EXML-3, sectionSize do
    local nextLine = i + IdLineOffsetInSection
  -- H.printf("  nextLine = %d",nextLine)
    local text = EXML[nextLine]
    local _,Id = GetPropertyNameValue(text)
  -- H.printf("    Id = [%s]",tostring(Id))
    local offsetLine = i + ValueLineOffsetInSection
  -- H.printf("  offsetLine = %d",offsetLine)
    local _,Value = GetPropertyNameValue(EXML[offsetLine])
  -- H.printf("    Value = [%s]",tostring(Value))
    Id_string[Id] = CharEntitiesReverse(Value)
    -- count = count + 1
    -- if count == 10 then
      -- WFAK()
    -- end
  end -- for i=startOfSection, #EXML-3, sectionSize do
  
  return Id_string
end
--***************************************************************************************************  

--***************************************************************************************************
-- transform a DICTIONARY table "values" into an Array
function DictValuesToArray(t1)
  local t2 = {}
  for _,v in pairs(t1) do
    t2[#t2+1] = v
  end
  return t2
end
--***************************************************************************************************

--***************************************************************************************************
-- clone a DICTIONARY table
function cloneDict(t1)
  local t2 = {}
  for k,v in pairs(t1) do
    t2[k] = v
  end
  return t2
end
--***************************************************************************************************

-- in LANGUAGE folder vs in EXML files
local langInEXML = {
  BRAZILIANPORTUGUESE = "BrazilianPortuguese",
  DUTCH = "Dutch",
  ENGLISH = "English",
  FRENCH = "French",
  GERMAN = "German",
  ITALIAN = "Italian",
  JAPANESE = "Japanese",
  KOREAN = "Korean",
  LATINAMERICANSPANISH = "LatinAmericanSpanish",
  POLISH = "Polish",
  PORTUGUESE = "Portuguese",
  RUSSIAN = "Russian",
  SIMPLIFIEDCHINESE = "SimplifiedChinese",
  SPANISH = "Spanish",
  TENCENTCHINESE = "TencentChinese",
  TRADITIONALCHINESE = "TraditionalChinese",
  USENGLISH = "USEnglish",
}

if not langInEXML[Language] then
  printf("@@@ [%s] is NOT a VALID LANGUAGE name, please correct!",Language)
  return
end

local realityList = {
  productTable         = "METADATA/REALITY/TABLES/NMS_REALITY_GCPRODUCTTABLE.MBIN",               -- 1: ID + Name + NameLower + Icon(Filename)
  substanceTable       = "METADATA/REALITY/TABLES/NMS_REALITY_GCSUBSTANCETABLE.MBIN",             -- 2: ID + Name + NameLower + Icon(Filename)
  proceduralTechTable  = "METADATA/REALITY/TABLES/NMS_REALITY_GCPROCEDURALTECHNOLOGYTABLE.MBIN",  -- 3: ID + Name + NameLower + Template(leads to icon in 4:)
  technologieTable     = "METADATA/REALITY/TABLES/NMS_REALITY_GCTECHNOLOGYTABLE.MBIN",            -- 4: ID + Name + NameLower + Icon(Filename)
  basepartproductsTable = "METADATA/REALITY/TABLES/NMS_BASEPARTPRODUCTS.MBIN",                    -- 5: ID + Name + NameLower + Icon(Filename)
  modularcustomisationproductsTable  = "METADATA/REALITY/TABLES/NMS_MODULARCUSTOMISATIONPRODUCTS.MBIN", -- 6: ID + Name + NameLower + Icon(Filename)
}

local globalsList = {
  "GLOBALS/GCDEBUGOPTIONS.GLOBAL.MBIN",
}

local languageList = {}

GetLanguages = nil -- to silence unused_variable NOTICE
function GetLanguages(TheData)
  --1: get the LocTableList from the SavedSection: "LocTableList"
  local languageListTable = TheData.Sections["LocTableList"]
  for i=1,#languageListTable do
    local v = string.match(languageListTable[i],[[ue="(.-)"]])
    if v then
      languageList[#languageList+1] = string.upper("LANGUAGE/"..v.."_"..Language..".MBIN")
    end
  end
  
  local list = {}
  for i=1,#languageList do
    list[#list+1] = languageList[i]
  end
  
  local langTable = 
      {
        MBIN_FS = list,
      }

  local mbin_ct = TheData["MBIN_CT"]
  table.insert(mbin_ct, TheData["MBIN_CT_Index"]+1, langTable)
  return "IGNORE"
end  

CreateDictionaries = nil -- to silence unused_variable NOTICE
function CreateDictionaries(TheData) -- called by AMUMSS
  -- Note: WE CAN NOT RELY ON CreateMapFileTree.lua to create the files in time for EXT_FUNC to process them

  -- 1a: get all language files for Language
  local entriesString = {}
  for i = 1,#languageList do
    entriesString[#entriesString+1] = TheData.ModdedMXMLs[NormalizePath(languageList[i],true)]
  end
  
  -- 1b: for each language file, get the Id and Value
  local fullLanguagesEntries = {}
  
  print("")
  local count = 0
  for i=1,#entriesString do
    printf(">>> %s",languageList[i])
    -- H.printf("    entriesString[i] = %d",#entriesString[i])
    local Id_string = GetId_String(entriesString[i])
    for k,v in pairs(Id_string) do
      -- we overwrite duplicates, keeping latest only
      fullLanguagesEntries[k] = v
      count = count + 1
    end
  end

  printf(">>> Found all %d distinct entries in all %s language files",count,Language)
  print("")
  
  -- 2a: get all reality files
  local realityTables = {}
  for k,v in pairs(realityList) do
    realityTables[k] = TheData.ModdedMXMLs[NormalizePath(v,true)]
  end

  local Dictionary = {}
  
  -- check itemTable validity
  local function CheckValid(t,i)
    local IsProblem = false
    if not t.source then IsProblem = true end 
    if not t.name then IsProblem = true end 
    if not t.icon then IsProblem = true end 
    if not t.category then IsProblem = true end 
    if IncludeDescriptions then
      if not t.description then IsProblem = true end 
    end
    
    if IsProblem then print("    Problem at "..i.." in "..tostring(t.source)..", "..tostring(t.name)..", "..tostring(t.category)..", "..tostring(t.icon)..", "..tostring(t.description)) end
    return IsProblem
  end
  
  ---[=[ Product =================================================================================
  local tableName = "productTable"
  local source = "Product"

  local itemTable = {}
  itemTable.source = source
  
  local duplicateItemLine = 0
  local item = ""
  local count = 0
  local i = 1
  while i <= #realityTables[tableName]-1 do
    local line1 = realityTables[tableName][i]
    local line2 = realityTables[tableName][i+1]
    
    -- if item ~= "" and (string.find(line1,[["GcProductData"]],1,true) or i == #realityTables[tableName]-1) then
    if item ~= "" and (string.find(line1,[["Table"]],1,true) or i == #realityTables[tableName]-1) then
      -- save information for previous item
      if Dictionary[item] then
        -- printf("@@@ [%s] already exist in Dictionary table.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
        -- print("       ==> Duplicate OR misspelling by HG")
      else
        local t = cloneDict(itemTable)
        CheckValid(t,duplicateItemLine)
        Dictionary[item] = t
      end
      count = count + 1
      -- and reset for next item
      itemTable = {}
      itemTable.source = source

      item = ""
    end
    
    if item == "" and string.find(line1,[["ID"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      item = v
      duplicateItemLine = i
    end

    if string.find(line1,[["NameLower"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.name = fullLanguagesEntries[v]
      if not itemTable.name then
        itemTable.name = [[NOT in LANGUAGE files]]
      end
    end

    if IncludeDescriptions then
      if string.find(line1,[["Description"]],1,true) then
        local _,v = GetPropertyNameValue(line1)
        itemTable.description = fullLanguagesEntries[v]
        if not itemTable.description then
          itemTable.description = [[NOT in LANGUAGE files]]
        end
      end
    end
    
    if not itemTable.icon and string.find(line1,[["Icon"]],1,true) then
      if string.find(line2,[["Filename"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.icon = v
      end
    end

    if not itemTable.category and string.find(line1,[["Type"]],1,true) then
      if string.find(line2,[["ProductCategory"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.category = v
      end
    end
    
    i = i + 1
  end
  
  print("")
  printf("%30s: found %d entries",source,count)
  --]=]
  
  ---[=[ BasepartProducts =================================================================================
  local tableName = "basepartproductsTable"
  local source = "BasepartProducts"

  local itemTable = {}
  itemTable.source = source
  
  local duplicateItemLine = 0
  local item = ""
  local count = 0
  local i = 1
  while i <= #realityTables[tableName]-1 do
    local line1 = realityTables[tableName][i]
    local line2 = realityTables[tableName][i+1]
    
    -- if item ~= "" and (string.find(line1,[["GcProductData"]],1,true) or i == #realityTables[tableName]-1) then
    if item ~= "" and (string.find(line1,[["Table"]],1,true) or i == #realityTables[tableName]-1) then
      -- save information for previous item
      if Dictionary[item] then
        -- printf("@@@ [%s] already exist in Dictionary table.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
        -- print("       ==> Duplicate OR misspelling by HG")
      else
        local t = cloneDict(itemTable)
        CheckValid(t,duplicateItemLine)
        Dictionary[item] = t
      end
      count = count + 1
      -- and reset for next item
      itemTable = {}
      itemTable.source = source

      item = ""
    end
    
    if item == "" and string.find(line1,[["ID"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      item = v
      duplicateItemLine = i
    end

    if string.find(line1,[["NameLower"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.name = fullLanguagesEntries[v]
      if not itemTable.name then
        itemTable.name = [[NOT in LANGUAGE files]]
      end
    end

    if IncludeDescriptions then
      if string.find(line1,[["Description"]],1,true) then
        local _,v = GetPropertyNameValue(line1)
        itemTable.description = fullLanguagesEntries[v]
        if not itemTable.description then
          itemTable.description = [[NOT in LANGUAGE files]]
        end
      end
    end
    
    if not itemTable.icon and string.find(line1,[["Icon"]],1,true) then
      if string.find(line2,[["Filename"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.icon = v
      end
    end

    if not itemTable.category and string.find(line1,[["Type"]],1,true) then
      if string.find(line2,[["ProductCategory"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.category = v
      end
    end
    
    i = i + 1
  end
  
  printf("%30s: found %d entries",source,count)
  --]=]
  
  ---[=[ ModularCustomisationProducts =================================================================================
  local tableName = "modularcustomisationproductsTable"
  local source = "ModularCustomisationProducts"

  local itemTable = {}
  itemTable.source = source
  
  local duplicateItemLine = 0
  local item = ""
  local count = 0
  local i = 1
  while i <= #realityTables[tableName]-1 do
    local line1 = realityTables[tableName][i]
    local line2 = realityTables[tableName][i+1]
    
    -- if item ~= "" and (string.find(line1,[["GcProductData"]],1,true) or i == #realityTables[tableName]-1) then
    if item ~= "" and (string.find(line1,[["Table"]],1,true) or i == #realityTables[tableName]-1) then
      -- save information for previous item
      if Dictionary[item] then
        -- printf("@@@ [%s] already exist in Dictionary table.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
        -- print("       ==> Duplicate OR misspelling by HG")
      else
        local t = cloneDict(itemTable)
        CheckValid(t,duplicateItemLine)
        Dictionary[item] = t
      end
      count = count + 1
      -- and reset for next item
      itemTable = {}
      itemTable.source = source

      item = ""
    end
    
    if item == "" and string.find(line1,[["ID"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      item = v
      duplicateItemLine = i
    end

    if string.find(line1,[["NameLower"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.name = fullLanguagesEntries[v]
      if not itemTable.name then
        itemTable.name = [[NOT in LANGUAGE files]]
      end
    end

    if IncludeDescriptions then
      if string.find(line1,[["Description"]],1,true) then
        local _,v = GetPropertyNameValue(line1)
        itemTable.description = fullLanguagesEntries[v]
        if not itemTable.description then
          itemTable.description = [[NOT in LANGUAGE files]]
        end
      end
    end
    
    if not itemTable.icon and string.find(line1,[["Icon"]],1,true) then
      if string.find(line2,[["Filename"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.icon = v
      end
    end

    if not itemTable.category and string.find(line1,[["Type"]],1,true) then
      if string.find(line2,[["ProductCategory"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.category = v
      end
    end
    
    i = i + 1
  end
  
  printf("%30s: found %d entries",source,count)
  --]=]
  
  ---[=[ Substance =================================================================================
  local tableName = "substanceTable"
  local source = "Substance"

  local itemTable = {}
  itemTable.source = source
  
  local duplicateItemLine = 0
  local item = ""
  local count = 0
  local i = 1
  while i <= #realityTables[tableName]-1 do
    local line1 = realityTables[tableName][i]
    local line2 = realityTables[tableName][i+1]
    
    --if item ~= "" and (string.find(line1,[["GcRealitySubstanceData"]],1,true) or i == #realityTables[tableName]-1) then
    if item ~= "" and (string.find(line1,[["Table"]],1,true) or i == #realityTables[tableName]-1) then
      -- save information for previous item
      if Dictionary[item] then
        -- printf("@@@ [%s] already exist in Dictionary table.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
        -- print("       ==> Duplicate OR misspelling by HG")
      else
        local t = cloneDict(itemTable)
        CheckValid(t,duplicateItemLine)
        Dictionary[item] = t
      end
      count = count + 1
      -- and reset for next item
      itemTable = {}
      itemTable.source = source

      item = ""
    end
    
    if item == "" and string.find(line1,[["ID"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      item = v
      duplicateItemLine = i
    end

    if string.find(line1,[["NameLower"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.name = fullLanguagesEntries[v]
      if not itemTable.name then
        itemTable.name = fullLanguagesEntries[string.gsub(v,"^UP_","")]        
        if not itemTable.name then
          itemTable.name = fullLanguagesEntries[string.gsub(v,"^T_","")]
          if not itemTable.name then
            itemTable.name = fullLanguagesEntries[string.gsub(v,"_NAME_L$","")]
            if not itemTable.name then
              itemTable.name = [[NOT in LANGUAGE files]]
            end
          end
        end
      end
    end
    
    if IncludeDescriptions then
      if string.find(line1,[["Description"]],1,true) then
        local _,v = GetPropertyNameValue(line1)
        itemTable.description = fullLanguagesEntries[v]
        if not itemTable.description then
          itemTable.description = [[NOT in LANGUAGE files]]
        end
      end
    end
    
    if not itemTable.icon and string.find(line1,[["Icon"]],1,true) then
      if string.find(line2,[["Filename"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.icon = v
      end
    end

    if not itemTable.category and string.find(line1,[["SubstanceCategory"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.category = v
    end
    
    i = i + 1
  end
  
  printf("%30s: found %d entries",source,count)
  --]=]
  
  ---[=[ Technology =================================================================================
  local tableName = "technologieTable"
  local source = "Technology"

  local itemTable = {}
  itemTable.source = source
  
  local duplicateItemLine = 0
  local item = ""
  local count = 0
  local i = 1
  while i <= #realityTables[tableName]-1 do
    local line1 = realityTables[tableName][i]
    local line2 = realityTables[tableName][i+1]
    
    -- if item ~= "" and (string.find(line1,[["GcTechnology"]],1,true) or i == #realityTables[tableName]-1) then
    if item ~= "" and (string.find(line1,[["Table"]],1,true) or i == #realityTables[tableName]-1) then
      -- save information for previous item
      if Dictionary[item] then
        -- printf("@@@ [%s] already exist in Dictionary table.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
        -- print("       ==> Duplicate OR misspelling by HG")
      else
        local t = cloneDict(itemTable)
        CheckValid(t,duplicateItemLine)
        Dictionary[item] = t
      end
      count = count + 1
      -- and reset for next item
      itemTable = {}
      itemTable.source = source

      item = ""
    end
    
    if item == "" and string.find(line1,[["ID"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      item = v
      duplicateItemLine = i
    end

    if string.find(line1,[["NameLower"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.name = fullLanguagesEntries[v]
      if not itemTable.name then
        itemTable.name = [[NOT in LANGUAGE files]]
      end
    end

    if IncludeDescriptions then
      if string.find(line1,[["Description"]],1,true) then
        local _,v = GetPropertyNameValue(line1)
        itemTable.description = fullLanguagesEntries[v]
        if not itemTable.description then
          itemTable.description = [[NOT in LANGUAGE files]]
        end
      end
    end
    
    if not itemTable.icon and string.find(line1,[["Icon"]],1,true) then
      if string.find(line2,[["Filename"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.icon = v
      end
    end

    if not itemTable.category and string.find(line1,[["Category"]],1,true) then
      if string.find(line2,[["TechnologyCategory"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.category = v
      end
    end
    
    i = i + 1
  end
  
  printf("%30s: found %d entries",source,count)
  --]=]
  
  ---[=[ Procedural =================================================================================
  local tableName = "proceduralTechTable"
  local source = "Procedural"

  local itemTable = {}
  itemTable.source = source
  
  local duplicateItemLine = 0
  local item = ""
  local count = 0
  local i = 1
  while i <= #realityTables[tableName]-1 do
    local line1 = realityTables[tableName][i]
    local line2 = realityTables[tableName][i+1]
    
    -- if item ~= "" and (string.find(line1,[["GcProceduralTechnologyData"]],1,true) or i == #realityTables[tableName]-1) then
    if item ~= "" and (string.find(line1,[["Table"]],1,true) or i == #realityTables[tableName]-1) then
      -- save information for previous item
      if Dictionary[item] then
        -- printf("@@@ [%s] already exist in Dictionary table.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
        -- print("       ==> Duplicate OR misspelling by HG")
      else
        local t = cloneDict(itemTable)
        CheckValid(t,duplicateItemLine)
        Dictionary[item] = t
      end
      count = count + 1
      -- and reset for next item
      itemTable = {}
      itemTable.source = source

      item = ""
    end
    
    if item == "" and string.find(line1,[["ID"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      item = v
      duplicateItemLine = i
    end

    if string.find(line1,[["NameLower"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.name = fullLanguagesEntries[v]
      if not itemTable.name then
        itemTable.name = fullLanguagesEntries[string.gsub(v,"^UP_","")]        
        if not itemTable.name then
          itemTable.name = fullLanguagesEntries[string.gsub(v,"^T_","")]
          if not itemTable.name then
            itemTable.name = fullLanguagesEntries[string.gsub(v,"_L$","")]
            if not itemTable.name then
              itemTable.name = fullLanguagesEntries[string.gsub(v,"_NAME_L$","")]
              if not itemTable.name then
                itemTable.name = [[NOT in LANGUAGE files]]
              end
            end
          end
        end
      end
    end

    if IncludeDescriptions then
      if string.find(line1,[["Description"]],1,true) then
        local _,v = GetPropertyNameValue(line1)
        itemTable.description = fullLanguagesEntries[v]
        if not itemTable.description then
          itemTable.description = [[NOT in LANGUAGE files]]
        end
      end
    end
    
    if not itemTable.icon and string.find(line1,[["Template"]],1,true) then
      local _,v = GetPropertyNameValue(line1)
      itemTable.icon = Dictionary[v].icon
      if not itemTable.icon then
        itemTable.icon = Dictionary[string.gsub(v,"^UP_","")].icon
        if not itemTable.icon then
          itemTable.icon = Dictionary[string.gsub(v,"^T_","")].icon
          if not itemTable.icon then
            itemTable.icon = Dictionary[string.gsub(v,"_NAME_L$","")].icon
          end
          if not itemTable.icon then
            printf("@@@ [%s] missing icon info.  On line %d of %s",item,duplicateItemLine,realityList[tableName])
          end
        end
      end
    end

    if not itemTable.category and string.find(line1,[["Category"]],1,true) then
      if string.find(line2,[["ProceduralTechnologyCategory"]],1,true) then
        local _,v = GetPropertyNameValue(line2)
        itemTable.category = v
      end
    end
    
    i = i + 1
  end
  
  printf("%30s: found %d entries",source,count)
  print("")
  --]=]
  
  return { 
            ["AMUMSS_Dictionary"]      = Dictionary, -- using reserved word AMUMSS_Dictionary
         }
end

NMS_MOD_DEFINITION_CONTAINER = 
{
  MOD_FILENAME 			= "NA.pak", -- irrelevant, no pak is created because no change are made to files
  MOD_DESCRIPTION		= "Creates/updates the 'Dictionary.lua' file in 'ModScript\ModHelperScripts'",
  MOD_AUTHOR				= "Wbertro/Mjstral/lMonk",
  LUA_AUTHOR				= "Wbertro",
  NMS_VERSION				= "4.70 and later",
  MODIFICATIONS 		=
	{
		{
			MBIN_CT = 
			{ 
				{
          MBIN_FS = globalsList,
          MXML_CT = {
            {
              PKW = "LocTableList",
              SEC_SAVE_TO = "LocTableList",
              SEC_KEEP = true,
            },
          },
          EXT_FUNC = {"GetLanguages",},
        },
        
        {
					-- MBIN_FS 	= tableUnion(true,languageList,realityList),-- open all required files
					MBIN_FS 	= DictValuesToArray(realityList),-- open all required files
          EXT_FUNC = {"CreateDictionaries",},
        },
        
      },
    }, 
	}, --1 global replacements
}
