local version = "1.0.0"

IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile("LoadHelpers.lua") end
H.THIS = "In CheckMods: "

local string = string
  local strsub = string.sub
  local strgsub = string.gsub
  local strfind = string.find
  local strmatch = string.match
  local strgmatch = string.gmatch
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

local DEBUG = false

local printfALT

local saveTo = [[..\TOOLS\EXML_Testing\]]

if DEBUG then
  printfALT = H.printf
else
  -- when NOT DEBUGGING
  printfALT = function() end
end
local IsDebugAnalyzeMXML = true -- DEBUG
local IsDebugWriteToFile = true -- DEBUG

local spacer = "  "

-- print()
-- print("THIS file (arg[0]) = "..tostring(arg[0]).." v"..version)
-- print()

-- print("Arguments passed to THIS script = "..tostring(#arg))
-- print()

if not H.IsFileExist("NMSMainFolders.txt") then
  print(H._zBRIGHTORANGE.." Missing some info to continue:"..H._zDEFAULT)
  print(H._zBRIGHTYELLOW.." ===>>> Please execute BUILDMOD.bat ONCE before retrying..."..H._zDEFAULT)
  return
end

local nmsMainFolders = H.ParseTextFileIntoTable("NMSMainFolders.txt")
-- create fast table
nmsMainFolders = H.ipairsFastTable(nmsMainFolders)

local MODS_list = H.ParseTextFileIntoTable([[MODS_pak_list.txt]])

-- detect BAD sub-folders in MODS
local badModsTable = {}
local IsGoodSubFolder = false
local firstTimeFirstFolderName = ""
local modName = ""
for i=1,#MODS_list do
  local s = MODS_list[i]
  if strfind(s,"Listing",1,true) then
    if firstTimeFirstFolderName ~= "" and not IsGoodSubFolder then
-- H.printf("- firstTimeFirstFolderName = [%s], IsGoodSubFolder = %s",firstTimeFirstFolderName,tostring(IsGoodSubFolder))
      badModsTable[modName] = true
    end
    IsGoodSubFolder = false -- reset
    firstTimeFirstFolderName = "" -- reset
    
-- H.printf("- [%s]",s)
    modName = strmatch(s,[[Listing (.*)$]])
-- H.printf("  - <%s>",modName)
    
  elseif modName ~= "" and H.trim(s) ~= "" then
-- H.printf("     = [%s]",s)
    -- remove the mod sub-folder name
    local filename, n = strgsub(s:upper(),H.escapeMagicString(modName)..[[\]],"",1) -- only 1st sub-folder name
    
    if n == 0 then
      -- there were no "\" to clean, a sign of problem
-- H.printf("BAD sub-folder when n = %d, [%s]",n,tostring(filename))
      badModsTable[modName] = true
      
    else
      -- filename is every thing after the mod sub-folder name
      local firstFolderName = strmatch(filename,[[^(.-)\]])
      if firstFolderName then
        if nmsMainFolders[firstFolderName] then
          -- a MAIN NMS folder: that should be a GOOD sub-folder mod
          IsGoodSubFolder = true
        else
          -- could be a custom folder
          -- but if all firstFolderName are the same, it is probably a BAD sub-folde mod
          if firstTimeFirstFolderName == "" then
            firstTimeFirstFolderName = firstFolderName
          elseif firstFolderName ~= firstTimeFirstFolderName then
            IsGoodSubFolder = true
          end
        end
      else
        -- when there is no firstFolderName
        IsGoodSubFolder = true
      end
    end
  end
end
-- for the last mod
if firstTimeFirstFolderName ~= "" and not IsGoodSubFolder then
  H.printf("- ON LAST MOD: firstTimeFirstFolderName = [%s], IsGoodSubFolder = %s",firstTimeFirstFolderName,tostring(IsGoodSubFolder))
  badModsTable[modName] = true
end

-- for k,v in pairs(H.gFastPAKlist) do
  -- if strfind(v,[[globals]],1,true) then
    -- H.printf(" *** [%s] = %s",k,v)
  -- end
-- end
-- H.WFAK()

local modsTable = {}
local modName = ""
for i=1,#MODS_list do
  local s = MODS_list[i]
  if strfind(s,"Listing",1,true) then
    -- H.printf("=========>>> IsGoodSubFolder = %s, IsCustomSubFolder = %s",tostring(IsGoodSubFolder),tostring(IsCustomSubFolder))
    -- if not IsGoodSubFolder and IsCustomSubFolder then
      -- print("              DECLARED BAD MOD FOLDER")
      -- badModsTable[modName] = true
    -- end
    -- IsGoodSubFolder = true -- reset
    -- IsCustomSubFolder = false -- reset
    
    -- H.printf("- [%s]",s)
    modName = strmatch(s,[[Listing (.*)$]])
    if badModsTable[modName] then
      -- skip this BAD sub-folder
      modName = ""
    else
      modsTable[modName] = {}
      -- H.printf("  - <%s>",modName)
    end
    
  elseif modName ~= "" and H.trim(s) ~= "" then
    -- H.printf("     = [%s]",s)
    -- local _,n = strgsub(s:upper(),H.escapeMagicString(modName)..[[\]],"",-1)
    -- remove the mod sub-folder name
    local filename, n = strgsub(s:upper(),H.escapeMagicString(modName)..[[\]],"")
    
    if n == 0 then
      -- there were no "\" to clean, a sign of problem
      -- H.printf("BAD sub-folder when n = %d",n)
      -- IsGoodSubFolder = false
      -- IsCustomSubFolder = true
      
    else
      -- filename is every thing after the mod sub-folder name
      -- H.printf("     filename = [%s]",filename)
      if filename and strfind(filename,[[.EXML]],1,true) or strfind(filename,[[.MXML]],1,true) or strfind(filename,[[.MBIN]],1,true) then
        local firstFolderName = strmatch(filename,[[^(.-)\]])
        if firstFolderName then
          if nmsMainFolders[firstFolderName] then
            -- a MAIN NMS folder
            local f = filename:gsub([[%.EXML$]],[[.MBIN]]):gsub([[%.MXML$]],[[.MBIN]])
            if H.gFastPAKlist[f] then
              -- H.printf("  ==>>> File found: [%s] [%s]",filename,f)
              modsTable[modName][#modsTable[modName] + 1 ] = filename
            else
              -- most probably a custom file
              -- H.printf("  ==>>> File not found: [%s] [%s]",filename,f)
            end
            -- IsGoodSubFolder = true
          -- else
            -- H.printf("POSSIBLE CUSTOM FOLDER: firstFolderName = [%s]",firstFolderName)
            -- IsCustomSubFolder = true
          end
        elseif strfind(filename,[[.MBIN]],1,true) and (strfind(filename,"GLOBALS.",1,true) or strfind(filename,".GLOBAL.",1,true)) then
          -- a ".MBIN GLOBALS.MBIN"
          modsTable[modName][#modsTable[modName] + 1 ] = filename
          -- IsGoodSubFolder = true
        elseif filename == "LOCTABLE.MXML" then
          modsTable[modName][#modsTable[modName] + 1 ] = filename
          -- IsGoodSubFolder = true
        -- else
          -- H.printf("BAD .EXML or .MXML  NOT in a sub-folder: firstFolderName = [%s]",firstFolderName)
          -- IsGoodSubFolder = false
        end
      end
    end
  end
end
-- -- for the last mod
-- H.printf("=========>>> IsGoodSubFolder = %s, IsCustomSubFolder = %s",tostring(IsGoodSubFolder),tostring(IsCustomSubFolder))
-- if not IsGoodSubFolder and IsCustomSubFolder then
  -- badModsTable[modName] = true
-- end
-- H.WFAK()

-- print()
-- print("ModPriority:")
local MODS_order_list = H.ParseTextFileIntoTable([[MODS_Report_list.txt]])
local modsOrder = {}
for i=1,#MODS_order_list do
  local s = MODS_order_list[i]
  -- H.printf("=== s = [%s]",tostring(s))
  if s then
    local modName = strmatch(s,[[^%s*%-%s-%d+%s.-%s(.+)]]):upper()
    local modPriority = tonumber(strmatch(s,[[^%s*%-%s-(%d+)]]))
    -- H.printf("===>> %3d %s",modPriority,modName)
    if modName then
      modsOrder[modName] = modPriority
      -- H.printf("%3d: [%s]",modsOrder[modName],modName)
    else
      H.printf(" WARNING: modName could not be retrieve from [%s]",tostring(s))
    end
  end
end


-- -- DEBUG
-- print()
-- for k,v in pairs(modsOrder) do
  -- H.printf("NNN [%3d] = [%s]",v,k)
-- end
-- print()

-- print()
-- print("B:")
local fileTableEXML = {}
local fileTableEXMLbadType = {}
local EXMLasMBIN = {}

local fileTableMXML = {}
local fileTableMBIN = {}

for k,v in pairs(modsTable) do
  for i=1,#v do
    local vv = v[i]:upper()
    -- H.printf("%s = [%s]",k,vv) -- sub-folder name, folder/file in it
    if strfind(vv,[[.EXML]],1,true) then
      if not H.IsEXMLType(vv) then
        fileTableEXMLbadType[#fileTableEXMLbadType+1] = {}
        fileTableEXMLbadType[#fileTableEXMLbadType][1] = k
        fileTableEXMLbadType[#fileTableEXMLbadType][2] = vv
      else
        if not fileTableEXML[vv] then
          fileTableEXML[vv] = {}
        end
        -- H.printf("   EXML: [%s]",vv)
        fileTableEXML[vv][#fileTableEXML[vv] + 1] = k
      end
      
      local f = H.gNMS_MODS_FOLDER..k..[[\]]..vv:gsub([[%.EXML$]],[[.MBIN]])
      if H.IsFileExist(f,true) then
        -- the MBIN also exist in the sub-folder
        -- H.printf("     ===>> [%s]",f)
        EXMLasMBIN[#EXMLasMBIN+1] = {}
        EXMLasMBIN[#EXMLasMBIN][1] = k -- sub-folder name
        EXMLasMBIN[#EXMLasMBIN][2] = vv:gsub([[%.EXML$]],[[.MBIN]]) -- MBINfilename
      end

    elseif strfind(vv,[[.MXML]],1,true) then
      if not fileTableMXML[vv] then
        fileTableMXML[vv] = {}
      end
      -- H.printf("   MXML: [%s] (%s)",vv,k)
      fileTableMXML[vv][#fileTableMXML[vv] + 1] = k
      
    elseif strfind(vv,[[.MBIN]],1,true) then
-- H.printf("@@@ MBIN: [%s]",vv)
      if not fileTableMBIN[vv] then
        fileTableMBIN[vv] = {}
      end
      fileTableMBIN[vv][#fileTableMBIN[vv] + 1] = k
-- H.printf("@@@    [%s]",fileTableMBIN[vv][#fileTableMBIN[vv]])
    end
  end
end
 
print()
print("  =====  =====  =====  =====  =====  =====  =====  =====")
print("  "..H._zWHITEonDARKCYAN.."                        RESULTS                       "..H._zDEFAULT)
print("  =====  =====  =====  =====  =====  =====  =====  =====")

print()
print("  "..H._zINVERSE.." ===== MODS sub-folders analysis ===== "..H._zDEFAULT)

local IsFirstTime = true
if next(badModsTable) then
  print()
  print(H._zWHITEonDARKCYAN..[[>>> PROBABLE malformed mod sub-folder in GAMEDATA\MODS: ]]..H._zDEFAULT)
  print(H._zBRIGHTYELLOW..[[       ===>> These GAMEDATA\MODS sub-folders may NOT be LOADED by the game]]..H._zDEFAULT)
  print(H._zBRIGHTYELLOW.."             Check your MODS sub-folder NAMES/CONTENT...:"..H._zDEFAULT)
  for k in pairs(badModsTable) do
    if IsFirstTime then
      IsFirstTime = false
      H.printf(spacer.."{ - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[k],k)
    else
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[k],k)
    end
  end
  if not IsFirstTime then
    print(spacer.."}")
  end
else
  print()
  print(H._zWHITEonDARKCYAN..">>> ALL MODS sub-folders look OK "..H._zDEFAULT)
end

print()
print("  "..H._zINVERSE.." ===== EXML files analysis ===== "..H._zDEFAULT)
local IsFirstTime = true
local exmlfilename = ""
for i=1,#fileTableEXMLbadType do
  if exmlfilename ~= fileTableEXMLbadType[i][1] then
    exmlfilename = fileTableEXMLbadType[i][1]
    if IsFirstTime then
      IsFirstTime = false
      print()
      print(H._zWHITEonDARKCYAN..">>> EXML used where a MBIN file is REQUIRED for this TYPE of files: "..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       ===>> THESE EXML files are of NO USE, the game will NOT use them!"..H._zDEFAULT)
      print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> [filename] )"..H._zDEFAULT)
      H.printf(spacer.."{ - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[fileTableEXMLbadType[i][1]],fileTableEXMLbadType[i][1])
    else
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[fileTableEXMLbadType[i][1]],fileTableEXMLbadType[i][1])
    end
  end
  H.printf(spacer.."         => %s",fileTableEXMLbadType[i][2])

end
if not IsFirstTime then
  print(spacer.."}")
end

local IsFirstTime = true
local exmlfilename = ""
for i=1,#EXMLasMBIN do
  if exmlfilename ~= EXMLasMBIN[i][1] then
    exmlfilename = EXMLasMBIN[i][1]
    if IsFirstTime then
      IsFirstTime = false
      print()
      print(H._zWHITEonDARKCYAN..">>> MBIN files also exist of the EXML that are quite probably MXML files: "..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       ===>> THESE MBIN files are going to be used by the game AND the EXML files are SUPERFLUOUS/IGNORED"..H._zDEFAULT)
      print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> [filename] )"..H._zDEFAULT)
      H.printf(spacer.."{ - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[EXMLasMBIN[i][1]],EXMLasMBIN[i][1])
    else
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[EXMLasMBIN[i][1]],EXMLasMBIN[i][1])
    end
  end
  H.printf(spacer.."         => %s",EXMLasMBIN[i][2])
end
if not IsFirstTime then
  print(spacer.."}")
end

local EXML_table = {} -- to unpack/decompile in H.ProcessMBINtable()
local IsFirstTime = true
for k,v in pairs(fileTableEXML) do
  EXML_table[#EXML_table+1] = strgsub(k,[[.EXML$]],[[.MBIN]])
  if #v > 1 then  
    if IsFirstTime then
      IsFirstTime = false
      print()
      print(H._zWHITEonDARKCYAN..">>> SAME EXML used by multiple mods: "..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       ===>> These mods should be OK to use together, as long as the EXMLs don't change the same values"..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       Otherwise, the mod with the lowest ModPriority value wins"..H._zDEFAULT)
      print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> )"..H._zDEFAULT)
      H.printf(" {".."%s:",k)
    else
      H.printf(spacer.."%s:",k)
    end

    for i=1,#v do
      -- H.printf("  - [%s]",v[i])
      -- H.printf("  - priority %d",modsOrder[v[i]])
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[v[i]],v[i])
    end
  end
end
if not IsFirstTime then
  print(spacer.."}")
end

if IsFirstTime then
  print()
  print(H._zWHITEonDARKCYAN..">>> No same EXML files used by multiple mods found "..H._zDEFAULT)
end

-- print()
-- print("MBIN to unpack/decompile:")
-- for i=1,#EXML_table do
  -- H.printf("  - [%s]",EXML_table[i])
-- end

-- unpack/decompile those files in EXML_table
H.EXMLorgTable = {}
H.EXMLmodTable = {}
H.gIs_LEAN_MODE = true -- mostly silent processing when true

H.NewThread([[CleanMod.bat]])
print()
print(H._zWHITEonDARKCYAN..">>> Analysing content of EXML files:"..H._zDEFAULT)
print(" ===> Retrieving original MXML files, be patient..."..H._zDEFAULT)
-- EXML_table with extension .MBIN
H.ProcessMBINtable(EXML_table,false,"","CheckMODS") -- ,IsCOMBINE_MODS_flag,_bScriptName,whichReport
-- decompiled files are in MODBUILDER\MOD

for i=1,#EXML_table do
  local filenameLess = EXML_table[i]:gsub([[%.MBIN$]],"") -- removed extension
  EXML_table[i] = filenameLess
  H.EXMLorgTable[filenameLess] = H.ParseTextFileIntoTable([[.\MOD\]]..filenameLess..[[.MXML]])
end

-- print()
-- print("H.EXMLorgTable: DEBUG")
-- for k,v in pairs(H.EXMLorgTable) do
  -- H.printf(" - %s (%d)",k,#v)
-- end

-- check each EXML against the original MXML to detect fake EXMLs
local EXMLasMXML = {}
print()
print(" ===> Comparing EXML and original MXML file content..."..H._zDEFAULT)
print("         Note: Large files can take a while..."..H._zDEFAULT)
for k,v in pairs(fileTableEXML) do -- k == EXMLfilename, v[x] == modname
  -- if #v > 1 then
    H.printf(spacer.."%s:",k)
    for i=1,#v do
-- H.printf("  - [%s]",v[i])
-- H.printf("  - priority %d",modsOrder[v[i]])

      local modEXML = H.ParseTextFileIntoTable(H.gNMS_MODS_FOLDER..v[i]..[[\]]..k)
      local top = H.GetTopOfMXML(modEXML)
      
      -- correct for bad formatted top (Data template) line, ex.: <!--File created using MBINCompiler version (5.58.0.3)--><Data template="cTkSceneNodeData">
      local DataStart = strfind(modEXML[top],"<Data",1,true)
      if DataStart > 1 then
        local s = strsub(modEXML[top],DataStart)
        modEXML[top] = strsub(modEXML[top],1,DataStart-1)
        table.insert(modEXML,top+1,s)
        top = top + 1
      end
      
      local modEXMLSize = H.GetBottomOfMXML(modEXML) - top + 1
      local orgMXMLSize = H.GetBottomOfMXML(H.EXMLorgTable[strgsub(k,[[.EXML$]],"")]) - H.GetTopOfMXML(H.EXMLorgTable[strgsub(k,[[.EXML$]],"")]) + 1
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN..[[%s\%s]]..H._zDEFAULT.."> (%d lines), (MXML %d lines)",modsOrder[v[i]],v[i],k,modEXMLSize,orgMXMLSize)
      
      if modEXMLSize == orgMXMLSize then
        -- this must be a MXML file in disguise
        EXMLasMXML[#EXMLasMXML+1] = {}
        EXMLasMXML[#EXMLasMXML][1] = k -- EXMLfilename
        EXMLasMXML[#EXMLasMXML][2] = v[i] -- modname
      else
        -- check that the EXML is well formed
        --   i.e.: no extra sections are present (all sections differ from original sections)

        local cOrg = H.cloneArray(H.EXMLorgTable[strgsub(k,[[.EXML$]],"")])
        local cMod = H.cloneArray(modEXML)
        
        -- local cOrg_scrubbed
        -- local cMod_scrubbed
        -- local IsSomeRemoved
        
        -- local scrubLevel = 3 -- was level 2
        -- cOrg_scrubbed, cMod_scrubbed, IsSomeRemoved = H.ScrubMXMLs(cOrg, cMod, scrubLevel)
        -- cOrg = cOrg_scrubbed
        -- cMod = cMod_scrubbed

        -- analyze the original MXML
        local TopOrg = H.GetTopOfMXML(cOrg)
        local stripOrgD, stripOrgI, sectionsOrgD, cOrg = H.AnalyzeXML("with #1 ORG with linked (if present)",cOrg,TopOrg,false,false)
        
        -- for cMod only: correct for possible bad _overwrite formating in the script
        for i=1,#cMod do
          local s = cMod[i]
          if strmatch(s:upper(),[[ _I]]) then
            -- only when detecting _id/_index
            if strfind(s,"[ _]overwrite") then
              cMod[i] = H.CheckOverwriteFormat(s)
            end
          end
        end

        local TopMod = H.GetTopOfMXML(cMod)
        local stripModD, stripModI, sectionsModD, cMod = H.AnalyzeXML("with #1 MOD WITH _overwrite and linked",cMod,TopMod,false,false)
        
        -- ==============================  
        local function SetKeepFlag(k,tD,tC,keep)
          if tD[k] then -- because it could be nil if the section does not exist
            for i=tD[k][1],tD[k][2] do
              if not strmatch(tC[i],keep) then
                tC[i] = tC[i]..keep
              end
            end
          end
        end
        -- ==============================  

        -- look for _overwrite OR linked= sections: these sections NEED to be KEPT
        -- <Property name="Table" value="GcPurchaseableSpecial" _id="BANNER_PEEP" _overwrite="true" />
        local IsKeepFlagAdded = false
        for i=1,#stripModI do
          local k = stripModI[i]
          if strmatch(k," _overwrite") or strmatch(k,[[ linked="]]) then
            -- set the KEEP flag
            
            -- printfALT(H.gcNOTICE.." [NOTICE]"..H._zDEFAULT.." Section %d-%d of MOD has been marked '# KEEP' for _overwrite/linked=",sectionsModD[k][1],sectionsModD[k][2])
            -- this section is marked with _overwrite in MOD by the script or is a linked= section
            SetKeepFlag(k, sectionsModD, cMod, H.modKEEP)
             -- strip from ORG, if present, because ORG does not have  _overwrite
             --     linked= is not a problem because both sides have linked=
            SetKeepFlag(k:gsub([[ _overwrite="true"]],""), sectionsOrgD, cOrg, H.modKEEP)
            
            IsKeepFlagAdded = true
          end
        end
        
        if IsKeepFlagAdded then
          -- redo the tables
          TopMod = H.GetTopOfMXML(cMod)
          stripModD, stripModI, sectionsModD, cMod = H.AnalyzeXML("with #2 MOD WITH KEEP + linked BUT no _overwrite",cMod,TopMod,true,false)
          printfALT("==> cMod: AnalyzeMXML redone WITH KEEP + linked BUT no _overwrite %s","")

          TopOrg = H.GetTopOfMXML(cOrg)
          stripOrgD, stripOrgI, sectionsOrgD, cOrg = H.AnalyzeXML("with #2 ORG WITH KEEP + linked",cOrg,TopOrg,false,false)
          printfALT("==> cOrg: AnalyzeMXML redone after KEEP flag added%s","")
        end
        
        -- check if all sections in MOD are different to ORG
        
        if IsDebugWriteToFile then H.WriteToFile(cOrg,saveTo..[[clonedORG.EXML]]) end
        if IsDebugWriteToFile then H.WriteToFileDictionary(stripOrgD,saveTo..[[stripOrgD.EXML]]) end
        if IsDebugWriteToFile then H.WriteToFile(stripOrgI,saveTo..[[stripOrgI.EXML]]) end
        -- WFAK("WAITING: 0: ")

              if IsDebugAnalyzeMXML then
                printfALT("   TopOrg = %d",TopOrg)
                local savePath = saveTo..[[clonedORG_1.EXML]]
                path = strgsub(savePath,[[%.EXML]],[[.stripOrgD.EXML]])
                local tmp = {}
                for i=1,#stripOrgI do
                  tmp[#tmp+1] = stripOrgI[i].." --> "..sectionsOrgD[stripOrgI[i]][1].."-"..sectionsOrgD[stripOrgI[i]][2]
                end
                H.WriteToFile(tmp,path)
              end
        
        if IsDebugWriteToFile then H.WriteToFile(cMod,saveTo..[[clonedMOD.EXML]]) end
        if IsDebugWriteToFile then H.WriteToFileDictionary(stripModD,saveTo..[[stripModD.EXML]]) end
        if IsDebugWriteToFile then H.WriteToFile(stripModI,saveTo..[[stripModI.EXML]]) end
        -- WFAK("WAITING: 1: ")

              if IsDebugAnalyzeMXML then
                printfALT("   TopMod = %d",TopMod)
                local savePath = saveTo..[[clonedMOD_1.EXML]]

                local path = strgsub(savePath,[[%.EXML]],[[.stripModD.EXML]])
                local tmp = {}
                for i=1,#stripModI do
                  tmp[#tmp+1] = stripModI[i].." --> "..sectionsModD[stripModI[i]][1].."-"..sectionsModD[stripModI[i]][2]
                end
                H.WriteToFile(tmp,path)
              end

        -- H.WFAK("Waiting after cMod and cOrg")
        
        -- for same section with only one value
        local sameSectionSizeLow = 3
        
        local prefixSpace = "          "
        local endMod = cMod
        for k,v in pairs(stripModD) do
          -- H.printf("%s",strsub(k,1,50).." ... "..strsub(k,-50))
          
          if stripOrgD[k] and H.trim(k) ~= "</Data>" then
            -- section exist in both Mod and Org
            if H.IsSectionsEqual(cMod, sectionsModD[k], cOrg, sectionsOrgD[k]) then
              -- sections ARE equal: this is a MALFORMED EXML
              -- printALT("                          ==> MOD == ORG")
              -- H.printf("%s: [%d] = [%s]",k,sectionsModD[k][1],cMod[sectionsModD[k][1]])
              
              -- we do not report ResHandle sections
              if strfind(cMod[sectionsModD[k][1]],[["ResHandle"]],1,true) == nil then
                if (sectionsModD[k][2] - sectionsModD[k][1]) < sameSectionSizeLow then
                  H.printf(prefixSpace..[[NOTICE: EXML section %d-%d is the same as MXML section %d-%d: possible MALFORMED EXML]],sectionsModD[k][1],sectionsModD[k][2],sectionsOrgD[k][1],sectionsOrgD[k][2])
                else
                  H.printf(prefixSpace..[[WARNING: EXML section %d-%d is the same as MXML section %d-%d: MALFORMED EXML]],sectionsModD[k][1],sectionsModD[k][2],sectionsOrgD[k][1],sectionsOrgD[k][2])
                end
                H.printf(prefixSpace..[[        The author may have INTENTIONNALY kept the section, only they know.   It could overwrite another MOD value, if loaded after it.]],"")
              end
              -- if strmatch(endMod[sectionsModD[k][1]],[[ linked=]]) then
                -- -- if a linked section, disregard KEEP and remove the section
                -- for i=sectionsModD[k][1],sectionsModD[k][2] do
                  -- endMod[i] = "r" -- signal remove
                -- end
              -- else
                -- -- remove section if not KEEP
                -- for i=sectionsModD[k][1],sectionsModD[k][2] do
                  -- if not strmatch(endMod[sectionsModD[k][1]],H.modKEEP) then
                    -- endMod[i] = "r" -- signal remove
                  -- end
                -- end
              -- end

            else
              -- sections NOT equal: no problem
              
              if strmatch(endMod[sectionsModD[k][1]],[[ linked=]]) then
                -- this is a 'linked' section
                --   the 'linked="xyz"' NOT removed: MALFORMED EXML
                H.printf(prefixSpace..[[WARNING: EXML contains Linked="ref": MALFORMED EXML]])
                
                -- endMod[sectionsModD[k][1]] = endMod[sectionsModD[k][1]]:gsub([[ linked=".-"]],"")..H.modLINKED

                -- -- ALREADY done by SetKeepFlag() above
                -- -- -- 2) this section to be keep as a linked section
                -- -- for i=sectionsModD[k][1] + 1, sectionsModD[k][2] do
                  -- -- endMod[i] = endMod[i]..H.modKEEP.."_B"
                -- -- end
              
              -- -- elseif strmatch(endMod[sectionsModD[k][1]],"[ _]overwrite") then
                -- -- -- this section to be kept as an _overwrite section
                -- -- for i=sectionsModD[k][1] + 1, sectionsModD[k][2] do
                  -- -- endMod[i] = endMod[i]..H.modKEEP.."_B"
                -- -- end
                
              -- else
                -- -- printfALT("         ==> MOD ~= ORG: %d-%d <=> %d-%d",sectionsModD[k][1],sectionsModD[k][2], sectionsOrgD[k][1],sectionsOrgD[k][2])
                -- moddedSections[#moddedSections+1] = {sectionsModD[k], sectionsOrgD[k]}
              end
              
            end -- if H.IsSectionsEqual(cMod, sectionsModD[k], cOrg, sectionsOrgD[k]) then
            
          -- else
            -- -- section only exist in Mod, keep it (default)
            -- -- printfALT("                          ==> NEW section in MOD: %d-%d",sectionsModD[k][1],sectionsModD[k][2])
          end -- if stripOrgD[k] and k ~= "</Data>" then 
        end -- for k,v in pairs(stripModD) do
        -- H.WFAK([[Waiting after checking for SAME sections and Linked="ref"]])

        -- check if Linked= sections in ORG are correct in MOD
        
      end -- if modEXMLSize == orgMXMLSize then
    end -- for i=1,#v do
  -- end -- if #v > 1 then
end -- for k,v in pairs(fileTableEXML) do -- k == EXMLfilename, v[x] == modname

local IsFirstTime = true
for i=1,#EXMLasMXML do
  if IsFirstTime then
    IsFirstTime = false
    print()
    print(H._zWHITEonDARKCYAN..">>> EXML that are quite probably MXML files: "..H._zDEFAULT)
    print(H._zBRIGHTYELLOW.."       If THESE EXML files are 'indeed' MXML files with value changes only, then"..H._zDEFAULT)
    print(H._zBRIGHTYELLOW.."       THESE EXML files are 'BAD USAGE' and should be made into real EXML files"..H._zDEFAULT)
    print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> [filename] )"..H._zDEFAULT)
    H.printf(" {".."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT.."> [%s]",modsOrder[EXMLasMXML[i][2]],EXMLasMXML[i][2],EXMLasMXML[i][1])
  else
    H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT.."> [%s]",modsOrder[EXMLasMXML[i][2]],EXMLasMXML[i][2],EXMLasMXML[i][1])
  end
end
if not IsFirstTime then
  print(spacer.."}")
end

-- check each EXML changed values against others mods EXML

print()
print("  "..H._zINVERSE.." ===== MBIN files analysis ===== "..H._zDEFAULT)
local MBINname = {}
  -- MBINname[#MBINname][1] = "MBIN(and other NMS files) or script or .txt name"
  -- MBINname[#MBINname][4] = "SCRIPTname"
  -- MBINname[#MBINname][2] = "upper SCRIPTname"
  -- MBINname[#MBINname][5] = "right userMODname"
  -- MBINname[#MBINname][3] = "right upper userMODname"
  -- MBINname[#MBINname][6] = combine #

local sameMBIN = {}
local diffMBIN = {}
local IsOneDifferent = false
local IsOneSame = false

local sameAs = [[: is the same as ]]
local differsFrom = [[: differs from ]]

-- -- debug
-- print()
-- for k,v in pairs(fileTableMBIN) do
  -- H.printf("CCC [%s]:",k)
  -- for i=1,#v do
    -- H.printf("CCC      - %d: [%s]",modsOrder[v[i]],v[i])
  -- end
-- end
-- print()

for k,v in pairs(fileTableMBIN) do
-- H.printf("[%s]:",k)
  if #v > 1 then
    for i=1,#v do
      -- local order = modsOrder[v[i]]
      local a = H.LoadFileData(H.gNMS_MODS_FOLDER..v[i]..[[\]]..k,"b")
      
      for j=i+1,#v do
        if v[i] ~= v[j] then
          local b = H.LoadFileData(H.gNMS_MODS_FOLDER..v[j]..[[\]]..k,"b")
          if a == b then
-- H.printf("   [%s] == [%s]",v[i],v[j])
            -- same exact MBIN files
            if not sameMBIN[k] then
              sameMBIN[k] = {}
            end
            sameMBIN[k][#sameMBIN[k]+1] = v[i]..sameAs..v[j]
            -- fileTableMBIN[k][j] = v[i]..sameAs..v[j]
            IsOneSame = true
          else
-- H.printf("   [%s] <> [%s]",v[i],v[j])
            -- different MBIN files
            if not diffMBIN[k] then
              diffMBIN[k] = {}
            end
            diffMBIN[k][#diffMBIN[k]+1] = v[i]..differsFrom..v[j]
            -- fileTableMBIN[k][j] = v[i]..[[: differs with ]]..v[j]
            IsOneDifferent = true
          end
          -- modsOrder[fileTableMBIN[k][j]] = order
        end
      end
    end
  end
end

local IsFirstTime = true
if IsOneSame then
  for k,v in pairs(sameMBIN) do
    if IsFirstTime then
      IsFirstTime = false
      print()
      print(H._zWHITEonDARKCYAN..">>> MBIN used by multiple mods: "..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       These mods share the exact "..H._zBRIGHTORANGE.."SAME"..H._zBRIGHTYELLOW.." MBIN"..H._zDEFAULT)
      print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> )"..H._zDEFAULT)
      H.printf(" {".."%s:",k)
    else
      H.printf(spacer.."%s:",k)
    end

-- H.printf("#v = %d",#v)
    for i=1,#v do
      local RightModName = strsub(v[i],strfind(v[i],sameAs,1,true)+#sameAs)
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[RightModName],RightModName)

      local LeftModName = strsub(v[i],1,strfind(v[i],":",1,true)-1)
      H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[LeftModName],LeftModName)

-- H.printf("   [%s] == [%s]",LeftModName,RightModName)
      -- H.printf(spacer.."  - <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",v[i])
    end
  end
end
if not IsFirstTime then
  print(spacer.."}")
end

local IsFirstTime = true
if IsOneDifferent then
  for k,v in pairs(diffMBIN) do
    if IsFirstTime then
      IsFirstTime = false
      print()
      print(H._zWHITEonDARKCYAN..">>> MBIN used by multiple mods (see after list for GROUPING suggestions): "..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       Mods that share the same MBIN file should be "..H._zBRIGHTORANGE.."COMBINED"..H._zBRIGHTYELLOW.."."..H._zDEFAULT)
      print(H._zBRIGHTYELLOW.."       Otherwise, for each MBIN file, only the mod with the lowest ModPriority value wins!"..H._zDEFAULT)
      print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> )"..H._zDEFAULT)
      H.printf(" {".."%s:",k)
    else
      H.printf(spacer.."%s:",k)
    end

-- H.printf("#v = %d",#v)
    local tmp = {}
    for i=1,#v do
      local RightModName = strsub(v[i],strfind(v[i],differsFrom,1,true)+#differsFrom)
      
      if not tmp[RightModName] then
        H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[RightModName],RightModName)
      end
      tmp[RightModName] = true

      local LeftModName = strsub(v[i],1,strfind(v[i],":",1,true)-1)
      
      if not tmp[LeftModName] then
        H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[LeftModName],LeftModName)
      end
      tmp[LeftModName] = true
      
      -- H.printf(spacer.."  - <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",v[i])

      MBINname[#MBINname+1] = {}
      MBINname[#MBINname][1] = k
      MBINname[#MBINname][2] = "SCRIPTNAME"
      MBINname[#MBINname][3] = RightModName:upper()
      MBINname[#MBINname][4] = "scriptname"
      MBINname[#MBINname][5] = RightModName
      MBINname[#MBINname][6] = nil

      MBINname[#MBINname+1] = {}
      MBINname[#MBINname][1] = k
      MBINname[#MBINname][2] = "SCRIPTNAME"
      MBINname[#MBINname][3] = LeftModName:upper()
      MBINname[#MBINname][4] = "scriptname"
      MBINname[#MBINname][5] = LeftModName
      MBINname[#MBINname][6] = nil
    end
  end
end
if not IsFirstTime then
  print(spacer.."}")
end

if #MBINname > 0 then
  print("")
  print("      "..H._zWHITEonDARKCYAN.."========= 'BASED on ABOVE MBIN conflicts', suggested COMBINE GROUPS are ========="..H._zDEFAULT)
  -- local pakList = {}
  -- print("")
  -- print("=== BY MBINname index ===")
  -- for i=1,#MBINname do
    -- pakList[#pakList+1] = MBINname[i][5]
    -- local v = MBINname
    -- H.printf("%3d    %-99s: [%s] [%s]",i,v[i][1],v[i][4],v[i][5])
  -- end
  
  local combineNumber = 1
  local index = 1
  -- for i=1,#pakList do
  repeat
    for i=1,#MBINname do
      if MBINname[i][6] == nil then
        index = i
        break
      end
    end

    local pakName = MBINname[index][5]
    -- H.printf("For %s",pakName)
    
    for j=1,#MBINname do
      if MBINname[j][6] == nil then
        -- this pak/mbin combo has not been attributed yet
        if MBINname[j][5] == pakName then
          -- H.printf("  A: at %d, tagged with %d",j,combineNumber)
          MBINname[j][6] = combineNumber
        end
      end
    end
    
    -- if one mbin entry is tagged, make all entries with the same mbin tagged also
    for j=1,#MBINname do
      if MBINname[j][6] ~= nil then
        -- this entry was tagged
        local combineNum =  MBINname[j][6]
        local mbinName = MBINname[j][1]
        -- tagged all entries with the same mbinName
        for k=1,#MBINname do
          if MBINname[k][1] == mbinName then
            if MBINname[k][6] == nil then
              -- H.printf("  B: at %d, tagged with %d",k,combineNum)
              MBINname[k][6] = combineNum
              
              -- this must be a different pakName, let us tag these too
              local pakName = MBINname[k][5]
              for m=1,#MBINname do
                if MBINname[m][6] == nil then
                  if MBINname[m][5] == pakName then
                    -- H.printf("  C: at %d, tagged with %d",m,combineNum)
                    MBINname[m][6] = combineNum
                  end
                end
              end
              
            end -- if MBINname[k][6] == nil then
          end -- if MBINname[k][1] == mbinName then
        end -- for k=1,#MBINname do
        
      end -- if MBINname[j][6] ~= nil then
    end -- for j=1,#MBINname do
    
    index = index + 1
    
    -- check if any entry left untagged
    local IsAllDone = true
    for j=1,#MBINname do
      if MBINname[j][6] == nil then
        combineNumber = combineNumber + 1
        -- H.printf("  X: at %d, tag incremented to %d",j,combineNumber)
        IsAllDone = false
        break
      end
    end
    
  until IsAllDone or index > #MBINname
  
  -- print("")
  -- print("=== COMBINE ===")
  -- for i=1,#MBINname do
    -- H.printf("    %-99s: %d [%s] [%s]",MBINname[i][1],MBINname[i][6],MBINname[i][4],MBINname[i][5],MBINname[i][6])
  -- end

  -- for i=1,#MBINname do
    -- H.printf("===============================================================================   <%s>",MBINname[i][3])
  -- end
    
  local donePakList = {}
  local group = 1
  repeat
    local IsGroupFound = false
    local IsFirst = true
    for j=1, #MBINname do
      if MBINname[j][6] == group then
        if IsFirst then
          print(H._zBRIGHTYELLOW.."      >>> GROUP #"..group..H._zDEFAULT)
          IsFirst = false
        end
        
        -- local luaName = luaEntries[strsub(MBINname[j][3],2,-2)] or "script UNKNOWN"
        -- local info = MBINname[j][5].." ["..luaName.."]"
        local info = "<"..H._zBRIGHTGREEN..MBINname[j][5]..H._zDEFAULT..">"

if modsOrder[MBINname[j][5]] == nil then
  H.printf("MBINname entry %d info:",j)
  for i=1,#MBINname[j] do
    H.printf("- [%s]",tostring(MBINname[j][i]))
  end
end
        -- record this mod done to prevent duplicates
        if not donePakList[MBINname[j][5]] then
          H.printf("        - %3d: %s",modsOrder[MBINname[j][5]],info)
          donePakList[MBINname[j][5]] = true
        end
        IsGroupFound = true
      end
    end
    
    if not IsGroupFound then
      print("")
    end
    
    group = group + 1
    
    -- if index <= #MBINname then
      -- H.printf("==================================================================================   %d %d %s",index,MBINname[index][6],MBINname[index][5])
    -- end
  until not IsGroupFound
end

if IsFirstTime then
  print()
  print(H._zWHITEonDARKCYAN..">>> No MBIN files conflict found "..H._zDEFAULT)
end

print()
print("  "..H._zINVERSE.." ===== LocTable.MXML files analysis ===== "..H._zDEFAULT)
local duplicateId = {}
local maxLength = 0
local IsFirstTime = true
if next(fileTableMXML) then
  print()
  print(H._zWHITEonDARKCYAN..">>> LocTable.MXML in multiple mods: "..H._zDEFAULT)
  print(H._zBRIGHTYELLOW.."       ALL LocTable.MXML files are COMBINED by NMS based on ModPriority"..H._zDEFAULT)
  print(H._zBRIGHTYELLOW..spacer.."( - ModPriority: <modName> )"..H._zDEFAULT)

  local Id = {}

  for k,v in pairs(fileTableMXML) do
    if #v > 1 then
      -- H.printf(spacer.."%s:",k)
      for i=1,#v do
        if IsFirstTime then
          IsFirstTime = false
          H.printf(spacer.."{ - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[v[i]],v[i])
        else
          H.printf(spacer.."  - %3d: <"..H._zBRIGHTGREEN.."%s"..H._zDEFAULT..">",modsOrder[v[i]],v[i])
        end
        
        local t = H.CreateLocTableTXTFromXML(H.ParseTextFileIntoTable(H.gNMS_MODS_FOLDER..v[i]..[[\LocTable.MXML]]))
        for j=1,#t do
          if strsub(t[j],1,1) == "=" then
            local id = strsub(t[j],2)
            -- H.printf("=== %s",id)
            if id ~= "" then
              if Id[id] then
                -- print("       duplicate")
                if duplicateId[id] then
                  duplicateId[id] = duplicateId[id].." - <"..H._zBRIGHTGREEN..v[i]..H._zDEFAULT..">"
                else
                  duplicateId[id] = "<"..H._zBRIGHTGREEN..v[i]..H._zDEFAULT.."> - <"..H._zBRIGHTGREEN..Id[id]..H._zDEFAULT..">"
                end
                maxLength = math.max(maxLength,#id)
              else
                Id[id] = v[i]
              end
            end
          end
        end -- for j=1,#t do
      end -- for i=1,#v do
    end -- if #v > 1 then
  end
  if not IsFirstTime then
    print(spacer.."}")
  end
else
  print()
  print(H._zWHITEonDARKCYAN..">>> No LocTable.MXML in use "..H._zDEFAULT)
end

local IsFirstTime = true
if next(duplicateId) then
  local width = maxLength + 2
  print()
  print("     "..H._zWHITEonDARKCYAN..[[>>> FOUND "Id" duplicates in LocTable.MXML files: ]]..H._zDEFAULT)
  -- print(H._zBRIGHTYELLOW.."       ALL LocTable.MXML files are COMBINED by NMS based on ModPriority"..H._zDEFAULT)
  print(H._zBRIGHTYELLOW..spacer.."(      - Id: <modName1> - <modName2> - <modname3> - ...)"..H._zDEFAULT)
  for k,v in pairs(duplicateId) do
    if IsFirstTime then
      IsFirstTime = false
      H.printf(spacer.."{    ".."  - %-"..width.."s : %s",k,v)
    else
      H.printf(spacer.."     ".."  - %-"..width.."s : %s",k,v)
    end
  end
else
  print()
  print("     "..H._zWHITEonDARKCYAN..[[>>> No duplicates found in LocTable.MXML files]]..H._zDEFAULT)
end
if not IsFirstTime then
  print(spacer.."}")
end

print()
print("TODO:")
print([[  - check if EXML files are changing the same values]])
print([[  - DONE: report EXML files that contain exact sub-sections of the original MXML]])
print([[  - DONE: confirm that EXML files are NOT disguised MBIN files]])
print([[  - DONE: report found EXML files for types that must be MBIN files]])
print([[  - DONE: report groups of mods with MBIN files that should be combined]])
print([[  - DONE: check if LocTable.MXMl files are changing the same values]])
print([[  - DONE: check if GAMEDATA\MODS sub-folders are really active mods]])

print()
H.LuaEndedOk(THIS)

-- H.WFAK()
