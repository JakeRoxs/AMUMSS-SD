-- for sub-sub-tables
local CONTAINERext2 = {
  FOREACH_SKW_GROUP = "string",
  FSKWG = "string", -- alias
  PRECEDING_KEY_WORDS = "string",
  PKW = "string", -- alias
  SPECIAL_KEY_WORDS = "string",
  SKW = "string", -- alias
  VALUE_CHANGE_TABLE = "string|number|nil|boolean|table",
  VCT = "string|number|nil|boolean|table", -- alias
  VALUE_MATCH = "string|number",
  WHERE_IN_SECTION = "string",
  WIS = "string", -- alias
  WHERE_IN_SUBSECTION = "string",
  WISS = "string", -- alias
  MBIN_FILE_SOURCE = "string",
  MBIN_FS = "string", -- alias
  REGEXAFTER = "string",
  REGEXBEFORE = "string",
}

-- for sub-tables
local CONTAINERext = {
  FILE_DESTINATION = "string",
  ADD = "string",
  AKW = "string",
  AFTER_KEY_WORDS = "string", -- alias
  CUSTOM_ORDER = "string",
  CO = "string", -- alias
  FOREACH_SKW_GROUP = "string|table",
  FSKWG = "string|table", -- alias
  LINE_OFFSET = "string|number",
  PRECEDING_KEY_WORDS = "string|table",
  PKW = "string|table", -- alias
  SEC_EDIT = "string",
  SECTION_ACTIVE = "number|string",
  SPECIAL_KEY_WORDS = "string|table",
  SKW = "string|table", -- alias
  VALUE_CHANGE_TABLE = "table",
  VCT = "table", -- alias
  VCT_COMMENT = "string",
  VALUE_MATCH = "string|number|table",
  WHERE_IN_SECTION = "table",
  WIS = "table", -- alias
  WHERE_IN_SUBSECTION = "table",
  WISS = "table", -- alias
  EXT_FUNC = "string",
  MBIN_FILE_SOURCE = "string|table",
  MBIN_FS = "string|table", -- alias
  REGEXAFTER = "table",
  REGEXBEFORE = "table",
}

local CONTAINER = {
    ADD_FILES = {
      COMMENT = "string",
      INTERNAL_FILE_SOURCE = "string",
      EXTERNAL_FILE_SOURCE = "string",
      FILE_CONTENT = "string",
      FILE_DESTINATION = "string|table",
    },
    AMUMSS_SUPPRESS_MSG = "string",
    -- COMPRESS_PAK = "string|boolean",
    EXML_CREATE = "string|boolean",
    GLOBAL_INTEGER_TO_FLOAT = "string",
    LUA_AUTHOR = "string",
    MOD_AUTHOR = "string",
    MOD_BATCHNAME = "string",
    MOD_CONTRIBUTORS = "string",
    MOD_DESCRIPTION = "string",
    MOD_FILENAME = "string",
    MOD_MAINTENANCE = "string",
    MODIFICATIONS = {
      MBIN_CHANGE_TABLE = {
        COMMENT = "string",
        EXML_CHANGE_TABLE = {
          ADD = "string|table",
          ADD_OPTION = "string",
          AKW = "string|table",
          AFTER_KEY_WORDS = "string|table", -- alias
          AUTO_GNH = "string|boolean",
          COMMENT = "string",
          CREATE_EXML = "string|boolean",
          CREATE_HOS = "string|boolean",
          CREATE_HOES = "string|boolean",
          CUSTOM_ORDER = "table",
          CO = "table", -- alias
          EXML_FLAGS = "string",
          EXML_ID = "string",
          EXML_INDEX = "number|string",
          FOREACH_SKW_GROUP = "table",
          FSKWG = "table", -- alias
          INTEGER_TO_FLOAT = "string",
          ITF = "string", -- alias
          LINE_OFFSET = "string|number|table",
          NOTICE_OFF = "string|boolean",
          MATH_OPERATION = "string",
          MATH_OP = "string", -- alias
          PRECEDING_FIRST = "string|boolean",
          PKW_1 = "string|boolean", -- alias
          PRECEDING_KEY_WORDS = "string|table",
          PKW = "string|table", -- alias
          REMOVE = "string",
          REPLACE_TYPE = "string",
          SEC_ADD_NAMED = "string",
          SECADD_COMMENT = "string",
          SEC_PASTE = "string", -- alias
          SEC_EDIT = "string|table",
          SEC_EMPTY = "string",
          SEC_KEEP = "string|boolean",
          SEC_SAVE_TO = "string",
          SEC_COPY = "string", -- alias
          SEC_UNSAVED = "string",
          SECTION_ACTIVE = "number|string|table",
          SECTION_UP = "number",
          SECTION_UP_SPECIAL = "number",
          SPECIAL_KEY_WORDS = "table",
          SKW = "table", -- alias
          SUB_LEVEL = "number",
          VALUE_CHANGE_TABLE = "table",
          VCT = "table", -- alias
          VCT_COMMENT = "table",
          VALUE_MATCH = "string|number|table",
          VALUE_MATCH_OPTIONS = "string",
          VALUE_MATCH_TYPE = "string",
          WHERE_IN_SECTION = "table",
          WIS = "table", -- alias
          WISEC_LOP = "string",
          WHERE_IN_SUBSECTION = "table",
          WISS = "table", -- alias
          WISUBSEC_LOP = "string",
          WISUBSEC_OPTION = "string",
        },
        EXML_CT = true, -- alias
        MXML_CHANGE_TABLE = {
          ADD = "string|table",
          ADD_OPTION = "string",
          AKW = "string|table",
          AFTER_KEY_WORDS = "string|table", -- alias
          AUTO_GNH = "string|boolean",
          COMMENT = "string",
          CREATE_EXML = "string|boolean",
          CREATE_HOS = "string|boolean",
          CREATE_HOES = "string|boolean",
          CUSTOM_ORDER = "table",
          CO = "table", -- alias
          EXML_FLAGS = "string",
          EXML_ID = "string",
          EXML_INDEX = "number|string",
          FOREACH_SKW_GROUP = "table",
          FSKWG = "table", -- alias
          INTEGER_TO_FLOAT = "string",
          ITF = "string", -- alias
          LINE_OFFSET = "string|number|table",
          NOTICE_OFF = "string|boolean",
          MATH_OPERATION = "string",
          MATH_OP = "string", -- alias
          PRECEDING_FIRST = "string|boolean",
          PKW_1 = "string|boolean", -- alias
          PRECEDING_KEY_WORDS = "string|table",
          PKW = "string|table", -- alias
          REMOVE = "string",
          REPLACE_TYPE = "string",
          SEC_ADD_NAMED = "string",
          SECADD_COMMENT = "string",
          SEC_PASTE = "string", -- alias
          SEC_EDIT = "string|table",
          SEC_EMPTY = "string",
          SEC_KEEP = "string|boolean",
          SEC_SAVE_TO = "string",
          SEC_COPY = "string", -- alias
          SEC_UNSAVED = "string",
          SECTION_ACTIVE = "number|string|table",
          SECTION_UP = "number",
          SECTION_UP_SPECIAL = "number",
          SPECIAL_KEY_WORDS = "table",
          SKW = "table", -- alias
          SUB_LEVEL = "number",
          VALUE_CHANGE_TABLE = "table",
          VCT = "table", -- alias
          VCT_COMMENT = "table",
          VALUE_MATCH = "string|number|table",
          VALUE_MATCH_OPTIONS = "string",
          VALUE_MATCH_TYPE = "string",
          WHERE_IN_SECTION = "table",
          WIS = "table", -- alias
          WISEC_LOP = "string",
          WHERE_IN_SUBSECTION = "table",
          WISS = "table", -- alias
          WISUBSEC_LOP = "string",
          WISUBSEC_OPTION = "string",
        },
        MXML_CT = true, -- alias
        EXML_CREATE = "string|boolean",
        EXT_FUNC = "table",
        MBIN_FILE_SOURCE = "string|table",
        MBIN_FS = "string|table", -- alias
        MBIN_FS_DISCARD = "string|boolean",
        REGEXAFTER = "table",
        REGEXBEFORE = "table",
      },
      MBIN_CT = true, -- alias
    },
    NMS_VERSION = "string|number",  
}

CONTAINER.MODIFICATIONS.MBIN_CT = CONTAINER.MODIFICATIONS.MBIN_CHANGE_TABLE
CONTAINER.MODIFICATIONS.MBIN_CHANGE_TABLE.EXML_CT = CONTAINER.MODIFICATIONS.MBIN_CHANGE_TABLE.EXML_CHANGE_TABLE
CONTAINER.MODIFICATIONS.MBIN_CHANGE_TABLE.MXML_CT = CONTAINER.MODIFICATIONS.MBIN_CHANGE_TABLE.MXML_CHANGE_TABLE

-- ================================
local CheckCONTAINER = true
local DEBUG = false
-- ================================

H.DelayedCONTAINERdata = {}

local function CheckIfTable(H,t,thisTableName,index)
  if index == nil then index = "" end
  if type(t) ~= "table" then
    H.printf("   >>> "..H.gcWARNING.." [WARNING] '%s[%d]' is not a table "..H._zDEFAULT,thisTableName,index)
    H.SetReportData(H.DelayedCONTAINERdata,"","'"..thisTableName.."["..index.."]' is not a table ","WARNING")
    return false
  end
  return true
end

local function CheckTableType(H,t,thisTableName,thisTableType)
  local tableType = H.GetTableType(t)
  if tableType == "Empty" and thisTableName == "MODIFICATIONS" then
    return false
  end
  if tableType ~= thisTableType then
    H.printf("  >>> "..H.gcWARNING.." [WARNING] BAD Table type: '%s' (%s)"..H._zDEFAULT,thisTableName,tableType)
    H.SetReportData(H.DelayedCONTAINERdata,"","BAD Table type: "..thisTableName.." ("..tableType..")","WARNING")
    return false
  end
  return true
end

local function CheckMasterType(H,masterType,k,v)
  if masterType == nil then return end
  
  local thisType = type(v)
  if DEBUG then H.printf("==> masterType [%s] = (%s), thisType = (%s)",k,masterType,thisType) end
  
  if not string.find(masterType,type(v),1,true) then
    print("   >>> "..H.gcWARNING.." [WARNING] Wrong type '"..thisType.."' for '"..tostring(k).."' in NMS_MOD_DEFINITION_CONTAINER "..H._zDEFAULT)
    H.SetReportData(H.DelayedCONTAINERdata,"","Wrong type ["..thisType.."] for ["..tostring(k).."] in NMS_MOD_DEFINITION_CONTAINER","WARNING")
  elseif thisType == "table" then
    local typeExt = CONTAINERext[k]
    if DEBUG then H.printf("==> For [%s], typeExt = (%s)",k,typeExt) end
    if typeExt then
      if CheckTableType(H,v,k,"Array") then
        for i=1,#v do
          local subTypeExt = type(v[i])
          if not string.find(typeExt,subTypeExt,1,true) then
            print("   >>> "..H.gcWARNING.." [WARNING] Wrong sub-type '"..type(v[i]).."' for '"..tostring(k).."["..i.."]' "..H._zDEFAULT)
            H.SetReportData(H.DelayedCONTAINERdata,"","Wrong sub-type ["..type(v[i]).."] for ["..tostring(k).."["..i.."]]","WARNING")
          elseif subTypeExt == "table" then
            if CheckTableType(H,v[i],k,"Array") then
              for j=1,#v[i] do
                local thisType = type(v[i][j])
                local typeExt2 = CONTAINERext2[k]
                if typeExt2 then
                  if k == "VALUE_CHANGE_TABLE" or k == "VCT" then
                    -- special case
                    if j < 3 and string.find("nil|table",thisType,1,true) then
                      print("   >>> "..H.gcWARNING.." [WARNING] Wrong sub-sub-type '"..thisType.."' for '"..tostring(k).."["..i.."]["..j.."]' "..H._zDEFAULT)
                      H.SetReportData(H.DelayedCONTAINERdata,"","Wrong sub-sub-type ["..thisType.."] for ["..tostring(k).."["..i.."]["..j.."]]","WARNING")
                    elseif j == 3 and not string.find("nil|string",thisType,1,true) then
                      print("   >>> "..H.gcWARNING.." [WARNING] Wrong sub-sub-type '"..thisType.."' for '"..tostring(k).."["..i.."]["..j.."]' "..H._zDEFAULT)
                      H.SetReportData(H.DelayedCONTAINERdata,"","Wrong sub-sub-type ["..thisType.."] for ["..tostring(k).."["..i.."]["..j.."]]","WARNING")
                    elseif j == 4 and not string.find(typeExt2,thisType,1,true) then
                      print("   >>> "..H.gcWARNING.." [WARNING] Wrong sub-sub-type '"..thisType.."' for '"..tostring(k).."["..i.."]["..j.."]' "..H._zDEFAULT)
                      H.SetReportData(H.DelayedCONTAINERdata,"","Wrong sub-sub-type ["..thisType.."] for ["..tostring(k).."["..i.."]["..j.."]]","WARNING")
                    end
                    
                  else                  
                    if not string.find(typeExt2,thisType,1,true) then
                      print("   >>> "..H.gcWARNING.." [WARNING] Wrong sub-sub-type '"..thisType.."' for '"..tostring(k).."["..i.."]["..j.."]' "..H._zDEFAULT)
                      H.SetReportData(H.DelayedCONTAINERdata,"","Wrong sub-sub-type ["..thisType.."] for ["..tostring(k).."["..i.."]["..j.."]]","WARNING")
                    end
                  end
                else
                  print("   >>> "..H.gcNOTICE.." [NOTICE] Missing entry '"..k.."' in 'CONTAINERext2' table "..H._zDEFAULT)
                  H.SetReportData(H.DelayedCONTAINERdata,"","Missing entry '"..k.."' in 'CONTAINERext2' table","NOTICE")
                end
              end
            end
          end
        end
      end
    else
      print("   >>> "..H.gcNOTICE.." [NOTICE] Missing entry '"..k.."' in 'CONTAINERext' table "..H._zDEFAULT)
      H.SetReportData(H.DelayedCONTAINERdata,"","Missing entry '"..k.."' in 'CONTAINERext' table","NOTICE")
    end
  end
end

if CheckCONTAINER then
  if DEBUG then H.printf("  '%s': %s","NMS_MOD_DEFINITION_CONTAINER",H.GetTableType(NMS_MOD_DEFINITION_CONTAINER)) end
  if CheckTableType(H,NMS_MOD_DEFINITION_CONTAINER,"NMS_MOD_DEFINITION_CONTAINER","Dictionary") then  
    for k,v in pairs(NMS_MOD_DEFINITION_CONTAINER) do
     if DEBUG then H.printf("B   '%s': %s",k,H.GetTableType(v)) end
      if not CONTAINER[k] then
        print("   >>> "..H.gcWARNING.." [WARNING] Unknown member '"..tostring(k).."' in NMS_MOD_DEFINITION_CONTAINER "..H._zDEFAULT)
        H.SetReportData(H.DelayedCONTAINERdata,"","Unknown member ["..tostring(k).."] in NMS_MOD_DEFINITION_CONTAINER","WARNING")
      end
      
      if k == "ADD_FILES" then
        if DEBUG then H.printf("    In '%s': type(%s)",k,type(v)) end
        if CheckIfTable(H,v,k) then
          if CheckTableType(H,v,k,"Array") then
            for i=1,#v do
              if CheckIfTable(H,v[i],k,i) then
                if CheckTableType(H,v[i],k.."["..i.."]","Dictionary") then
                  for mk,mv in pairs(v[i]) do
                    if DEBUG then H.printf("G      #%d: found '%s' (%s)",i,mk,type(mv)) end
                    
                    if not CONTAINER[k][mk] then
                      H.printf("      >>> "..H.gcWARNING.." [WARNING] Unknown member '%s' in %s[%d] "..H._zDEFAULT,tostring(mk),k,i)
                      H.SetReportData(H.DelayedCONTAINERdata,"","Unknown member '"..tostring(mk).."' in "..k.."["..i.."]","WARNING")
                    else
                      CheckMasterType(H,CONTAINER[k][mk],mk,mv)
                    end
                  end
                end
              end
            end
          end
        end
        
      elseif k == "MODIFICATIONS" then
        if CheckTableType(H,v,k,"Array") then
          if DEBUG then H.printf("C   '%s': %s",k,H.GetTableType(v)) end
          for i=1,#v do
            if CheckIfTable(H,v[i],k,i) then
              if CheckTableType(H,v[i],k.."["..i.."]","Dictionary") then
                for mk,mv in pairs(v[i]) do
                  if DEBUG then H.printf("D      #%d: found '%s'",i,mk) end
                  
                  if not CONTAINER[k][mk] then
                    H.printf("      >>> "..H.gcWARNING.." [WARNING] Unknown member '%s' in %s[%d] "..H._zDEFAULT,tostring(mk),k,i)
                    H.SetReportData(H.DelayedCONTAINERdata,"","Unknown member '"..tostring(mk).."' in "..k.."["..i.."]","WARNING")
                  end
                  
                  if mk == "MBIN_CHANGE_TABLE" or mk == "MBIN_CT" then
                    if CheckTableType(H,mv,mk,"Array") then
                      for j=1,#mv do
                        if DEBUG then H.printf("E         #%d: %s",j,H.GetTableType(mv[j])) end
                        if CheckIfTable(H,mv[j],mk,j) then
                          if CheckTableType(H,mv[j],mk.."["..j.."]","Dictionary") then
                            for pk,pv in pairs(mv[j]) do
                              if DEBUG then H.printf("H               Looking at '%s' (%s)",pk,type(pk)) end
                              if not CONTAINER[k][mk][pk] then
                                H.printf("               >>> "..H.gcWARNING.." [WARNING] Unknown member '%s' in %s[%d] "..H._zDEFAULT,tostring(pk),mk,j)
                                H.SetReportData(H.DelayedCONTAINERdata,"","Unknown member '"..tostring(pk).."' in "..mk.."["..j.."]","WARNING")
                              end
                              
                              if pk == "MXML_CHANGE_TABLE" or pk == "MXML_CT" or pk == "EXML_CHANGE_TABLE" or pk == "EXML_CT" then
                                if CheckTableType(H,pv,pk,"Array") then
                                  for j=1,#pv do
                                    if DEBUG then H.printf("F                  #%d: %s",j,H.GetTableType(pv[j])) end
                                    if CheckIfTable(H,pv[j],pk,j) then
                                      if CheckTableType(H,pv[j],pk.."["..j.."]","Dictionary") then
                                        for qk,qv in pairs(pv[j]) do
                                          if DEBUG then H.printf("G                     Looking at '%s' (%s)",qk,type(qk)) end
                                          if not CONTAINER[k][mk][pk][qk] then
                                            H.printf("                     >>> "..H.gcWARNING.." [WARNING] Unknown member '%s' in %s[%d] "..H._zDEFAULT,tostring(qk),pk,j)
                                            H.SetReportData(H.DelayedCONTAINERdata,"","Unknown member '"..tostring(qk).."' in "..pk.."["..j.."]","WARNING")
                                          else
                                            CheckMasterType(H,CONTAINER[k][mk][pk][qk],qk,qv)
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              else
                                CheckMasterType(H,CONTAINER[k][mk][pk],pk,pv)
                              end -- if not CONTAINER[k][mk][pk] then

                            end -- for pk,pv in pairs(mv[j]) do
                          end -- if CheckTableType(mv[j],mk.."["..j.."]","Dictionary") then
                        end -- if CheckIfTable(mv[j],mk,j) then
                      end -- for j=1,#mv do
                    end -- if CheckTableType(mv,mk,"Array") then
                  else
                    CheckMasterType(H,CONTAINER[k][mk],mk,mv)
                  end -- if not CONTAINER[k][mk] then
                end -- for mk,mv in pairs(v[i]) do
              end -- if CheckTableType(v[i],k.."["..i.."]","Dictionary") then
            end -- if CheckIfTable(v[i],k,i) then
          end -- for i=1,#v do
        end -- if CheckTableType(v,k,"Array") then
      else
        CheckMasterType(H,CONTAINER[k],k,v)
      end -- if not CONTAINER[k] then
    end -- for k,v in pairs(NMS_MOD_DEFINITION_CONTAINER) do
    
  end -- if tableType == "Dictionary" then

  if #H.DelayedCONTAINERdata == 0 then
    print(">>> "..H._zBRIGHTORANGE.."Enhanced Analysis completed successfully"..H._zDEFAULT)
    H.SetReportData(H.DelayedCONTAINERdata,"","Enhanced Analysis completed successfully","")
  end
end -- if CheckCONTAINER then

-- H.ReportDelayedInfo(H.DelayedCONTAINERdata)
