-- ****************************************************
-- main
-- ****************************************************

--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER
--arg[3] == a message --not used
--arg[4] == 1 (check NMS MODS for conflict)
--arg[5] == 1 (called from _Check_CONFLICTS_in_MODS.bat)

if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
H.pv(">>>     In CheckCONFLICTLOG.lua")
H.gfilePATH = arg[1] --used by LoadHelpers.Report()
THIS = "In CheckCONFLICTLOG: "

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

local LDebug = LDebug

-- print("          lfs = "..lfs.currentdir())
-- print("AAAAAA arg[1] = ["..tostring(arg[1]).."]")
-- print("AAAAAA arg[2] = ["..tostring(arg[2]).."]")
-- print("AAAAAA arg[3] = ["..tostring(arg[3]).."]")
-- print("AAAAAA arg[4] = ["..tostring(arg[4]).."]")
-- print("AAAAAA arg[5] = ["..tostring(arg[5]).."]")

-- -- H.Report(arg[3])
-- local LogTable = H.ParseTextFileIntoTable(arg[1]..[[REPORT.lua]])

-- %_bCheckMODSconflicts% EQU 1 >>> Y both MODS and Scripts
-- %_bCheckMODSconflicts% EQU 2 >>> None
-- %_bCheckMODSconflicts% EQU 3 >>> MODS only
-- %_bCheckMODSconflicts% EQU 4 >>> Scripts only

local IsCheckMODSconflicts   = (arg[4] == "1") or (arg[4] == "3")
local IsCheckSCRIPTconflicts = (arg[4] == "1") or (arg[4] == "4")

local IsCalledFromCheckConflictsInMODS = (arg[5] == "1")

local sTime = os.clock()

-- print("AAAAAA             IsCheckMODSconflicts = "..tostring(IsCheckMODSconflicts))
-- print("AAAAAA           IsCheckSCRIPTconflicts = "..tostring(IsCheckSCRIPTconflicts))
-- print("AAAAAA IsCalledFromCheckConflictsInMODS = "..tostring(IsCalledFromCheckConflictsInMODS))

local ConflictScriptTable = {}
local State = ""
local filehandle 

-- WBERTRO: replacing ModScript_pak_list with MODS_pak_list

if IsCheckMODSconflicts or IsCheckSCRIPTconflicts then
  if IsCheckMODSconflicts and IsCheckSCRIPTconflicts then
    -- load info from 'ModScripts' scripts and paks
    filehandle = io.open(arg[2]..[[MBIN_PAKS.txt]],"a+")
    -- also will need to merge MODS_pak_list into MBIN_PAKS
    State = "BOTH"
  
  elseif IsCheckMODSconflicts then
    -- erase previous info from MBIN_PAKS.txt
    -- and load info from MODS
    filehandle = io.open(arg[2]..[[MBIN_PAKS.txt]],"w+")
    State = "MODS"
  
  elseif IsCheckSCRIPTconflicts then
    -- load info from 'ModScripts' scripts and paks
    -- info is already in the right format
    -- filehandle will be nil
    ConflictScriptTable = H.ParseTextFileIntoTable(arg[2]..[[MBIN_PAKS.txt]])
    State = "ModScript"
  end
  
  if filehandle then
    -- load info from MODS
    local MODSTable = H.ParseTextFileIntoTable(arg[2]..[[MODS_pak_list.txt]])
    
    local userPAKname = ""
    for i=1,#MODSTable do
      local text = MODSTable[i]
      if text and H.trim(text) ~= "" then
        if strsub(text,1,7) == "Listing" then
          userPAKname = strsub(text,9)
        elseif strsub(text,1,5) == "FROM " then
          --skip this line
          -- if strsub(text,6) == "MODS" then
          -- else 
            -- -- "ModScript"
          -- end
        else
          -- local pakFile = strgsub(H.StripInfo(text,[[]],[[ (]]),[[/]],[[\]])
          local pakFile = strgsub(text,[[/]],[[\]])
          -- because some user pak file list may start with / or other non-letters
          local start = strfind(pakFile,"%a")
          if start then
            pakFile = strsub(pakFile,start)
            filehandle:write(pakFile..", : "..userPAKname.."\n")
          else
            --there are no 'letters' found in pakFile(aka text)
            print(">>> "..H.gcNOTICE.." [NOTICE] Problem getting info from ["..text.."]"..H._zDEFAULT)
            H.Report("","Problem getting info from ["..text.."]","NOTICE")
          end
        end
      end
    end
    filehandle:flush()
    filehandle:close()
  end
  
  -- here MBIN_PAKS.txt contains both MODS and ModScript MBIN lists
  ConflictScriptTable = H.ParseTextFileIntoTable(arg[2]..[[MBIN_PAKS.txt]])
  
-- elseif IsCheckMODSconflicts then
  -- -- load info from MODS
  -- ConflictScriptTable = H.ParseTextFileIntoTable(arg[2]..[[MODS_pak_list.txt]])
  -- State = "MODS"
  
-- elseif IsCheckSCRIPTconflicts then
  -- -- load info from ModScripts scripts and paks
  -- ConflictScriptTable = H.ParseTextFileIntoTable(arg[2]..[[MBIN_PAKS.txt]])
  -- State = "ModScript"
  
else
  -- nothing to do
end

-- print("AAAAAA #ConflictScriptTable = ["..tostring(#ConflictScriptTable).."]")

-- do we do Conflicts checking?
if IsCheckMODSconflicts or IsCheckSCRIPTconflicts then
  local CST = {}
  for i=1,#ConflictScriptTable do
    local text = ConflictScriptTable[i]
    if text and H.trim(text) ~= "" then
      CST[#CST+1] = strgsub(text,[[/]],[[\]])
    end
  end

  if IsCheckMODSconflicts and IsCheckSCRIPTconflicts then
    print()
    print(H._zBRIGHTGREEN..">>> Checking Conflicts in ModScript Scripts/paks and NMS MODS paks. Please wait..."..H._zDEFAULT)
    
    H.Report("")
    H.Report("","Checked Conflicts in ModScript Scripts/paks and NMS MODS paks.")
    H.Report("")
  end
  
  if not IsCheckMODSconflicts then
    print()
    print("===== Conflicts in NMS MODS are NOT checked at user request =====")
    print(H._zBRIGHTGREEN..">>> Checking Conflicts in ModScript Scripts/paks only. Please wait..."..H._zDEFAULT)

    H.Report("")
    H.Report("","===== Conflicts in NMS MODS were NOT checked at user request =====")
    H.Report("","<<< ONLY Checked Conflicts in ModScript Scripts/paks. >>>")
    H.Report("")
  end

  if not IsCheckSCRIPTconflicts then
    print()
    print("===== Conflicts in ModScript are NOT checked at user request =====")
    print(H._zBRIGHTGREEN..">>> Checking Conflicts in MODS folder only. Please wait..."..H._zDEFAULT)

    H.Report("")
    H.Report("","===== Conflicts in ModScript were NOT checked at user request =====")
    H.Report("","<<< ONLY Checked Conflicts in MODS folder. >>>")
    H.Report("")
  end

-- print("AAAAAA >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>     DEBUG State = ["..State.."]")

  -- ****************************************************
  -- remove duplicate lines: VERY FAST
  local function RemoveDuplicates(t,stype)
    local outTable = {}
    if #t > 1 then
      print(strformat(H._zBRIGHTGREEN.."      - Pruning %s in %u files..."..H._zDEFAULT,stype,#t))
      
      local tmp = {}
      local m = 1
      for i=1,#t do
        if tmp[t[i]] == nil then
          tmp[t[i]] = m -- so we keep numerical continuity
          m = m + 1
        end
      end

      for k,v in pairs(tmp) do
        outTable[v] = k
      end
      
    else
      -- print("                                    >>>>>>>>> RETURNING original table!!!")
      outTable = t
    end
    return outTable
  end
  --END: remove duplicate lines
  -- ****************************************************  
  
  -- print("AAAAAA      #CST = ["..tostring(#CST).."]")
  CSTable = RemoveDuplicates(CST,"duplicates")  
  -- print("AAAAAA  #CSTable = ["..tostring(#CSTable).."]")

  -- print(" = = = = = =")
  -- for i=1,#CSTable do
    -- print(" * ["..CSTable[i].."]")
  -- end
  -- print("END: = = = = = =")

  -- Keep conflicting entries only
  local ConflictingEntries = {}
  local tmp = {}
  local luaEntries = {} -- to record script name for each pak in MODS
  
  for i=1,#CSTable do
    local text = strupper(H.StripInfo(CSTable[i],[[]],[[,]]))
    local pak = strupper(H.StripInfo(CSTable[i],[[: ]]))
    -- H.printf(" - %s [%s] <%s>",text,strsub(text,-4),pak)
    if strsub(text,-4) == [[.LUA]] then
      if luaEntries[pak] then
        luaEntries[pak] = [["Combined pak, multiple scripts"]]
      else
        luaEntries[pak] = H.StripInfo(CSTable[i],[[]],[[,]])
      end
    end
    -- H.printf("[%s] %s",strsub(text,-4),luaEntries[pak])

    if tmp[text] and strsub(text,-4) ~= [[.TXT]] then
      -- print("   -> "..text)
      -- entry already exist
      -- this must be a conflicting entry, remember it
      ConflictingEntries[#ConflictingEntries + 1] = tmp[text]
      ConflictingEntries[#ConflictingEntries + 1] = CSTable[i]

    else
      -- H.printf("     => [%s] = [%s]",text,CSTable[i])
      tmp[text] = CSTable[i]
    end
  end

  -- print(" = = = = = = MBIN and pak")
  -- for i=1,#ConflictingEntries do
    -- print(" + ["..ConflictingEntries[i].."]")
  -- end
  -- print("END: = = = = = =")
  
  -- print(" = = = = = = pak and script")
  -- for k,v in pairs(luaEntries) do
    -- H.printf("   [%s] = [%s]",k,v)
  -- end
  -- print("END: = = = = = =")

  CSTable = RemoveDuplicates(ConflictingEntries,"conflicting entries")
  -- print("CCCCC #CSTable = ["..tostring(#CSTable).."]")
  
  -- for i=1,#CSTable do
    -- H.Report(""," = ["..CSTable[i].."]")
  -- end
  
  -- pre-process CSTable info
  MBINname = {}

  for i=1,#CSTable do
    local text = CSTable[i]

    MBINname[#MBINname+1] = {}
    
    MBINname[#MBINname][1] = [["]]..strupper(H.StripInfo(text,[[]],[[,]]))..[["]] -- MBIN(and other NMS files) or script or .txt name
      
    MBINname[#MBINname][5] = [["]]..H.StripInfo(text,[[: ]])..[["]] -- userPAKname
    MBINname[#MBINname][3] = strupper(MBINname[#MBINname][5])       -- upper userPAKname

    if not IsCalledFromCheckConflictsInMODS then
      -- will be empty if in MODS
      MBINname[#MBINname][4] = [["]]..H.StripInfo(text,[[, ]],[[:]])..[["]] -- SCRIPTname
      MBINname[#MBINname][2] = strupper(MBINname[#MBINname][4])                 -- upper SCRIPTname
    end
  end
  
-- print("AAAAAA #MBINname = ["..tostring(#MBINname).."]")
-- print("AAAAAA MBINname[1] = ["..tostring(MBINname[1][1]).." >>> "..tostring(MBINname[1][2]).." >>> "..tostring(MBINname[1][3]).."]")
-- print("AAAAAA startOfMODSlist = "..tostring(startOfMODSlist))  

  if #MBINname - 1 > 0 then
    if #MBINname > 1 then
      print(H._zBRIGHTGREEN.."      - We have "..#MBINname.." possible conflicting files to process!  WORKING..."..H._zDEFAULT)
    else
      print(H._zBRIGHTGREEN.."      - We have "..#MBINname.." possible conflicting file to process!  WORKING..."..H._zDEFAULT)
    end
  end

  H.Report("","======== CONFLICTS at FILE level (conflicts of individual values are NOT checked) ======={")
    
  -- ****************************************************
  local function ShowInfo(t,luaEntries)
    -- print("AAAAAA In ShowInfo() with ["..t[2].."]")
    local IsOnlyScript = true
    if not IsCalledFromCheckConflictsInMODS and H.trim(t[2]) ~= [[""]] then
      local tmp = [["SCRIPT in Modscript\]]..strsub(t[4],2)
      H.Report("","\t- "..tmp,"     >>>")
    else
      local thisPAKname = t[5]:sub(2)
      local comingFrom = [["MODS\]]
      
      if not IsCalledFromCheckConflictsInMODS then
        local start,stop = strfind(thisPAKname,[[..\ModScript\]],1,true)
        if stop then
          thisPAKname = strsub(thisPAKname,stop+1)
          comingFrom = [["SCRIPT in Modscript\]]
        else
          IsOnlyScript = false
        end
      else
        IsOnlyScript = false
      end
      
      local thisScriptName = ""
      if not IsOnlyScript then
        -- H.printf("{%s}",strupper(strsub(thisPAKname,1,-2)))
        thisScriptName = luaEntries[strupper(strsub(thisPAKname,1,-2))]
        if thisScriptName and thisScriptName ~= "" then
          thisScriptName = " ["..thisScriptName.."]"
        else
          thisScriptName = " (script UNKNOWN)"
        end
      end
      
      H.Report("","\t- "..comingFrom..thisPAKname..thisScriptName,"     >>>")
    end
    return IsOnlyScript
  end
  -- ****************************************************
  
  -- create list of conflicts by MBIN files in one pass
  local tmpList = {}
  local conflictCount = 0
  for i=1,#MBINname do
    local name = MBINname[i][1]
    if tmpList[name] then
      -- already exist: a conflict
      -- record this 
      tmpList[name][#tmpList[name]+1] = MBINname[i]
      
    else
      -- does not already exist
      conflictCount = conflictCount + 1
      tmpList[name] = {}
      tmpList[name][#tmpList[name]+1] = MBINname[i]
    end
  end
  
  -- print("")
  -- print("=== BY MBIN FILES ===")
  -- for k,v in pairs(tmpList) do
    -- for i=1,#v do
      -- H.printf("    %-99s: [%s] [%s]",v[i][1],v[i][4],v[i][5])
    -- end
  -- end
  
  -- print("FFFFF #tmpList = ["..conflictCount.."]")
  -- END: create list of conflicts

  -- for even faster access
  local LFastPAKlist = H.gFastPAKlist
  
  -- Report the conflicts
  for k,v in pairs(tmpList) do
    local NMSPAKname = LFastPAKlist[strsub(v[1][1],2,#v[1][1] - 1)]
    if NMSPAKname == nil then 
      NMSPAKname = "File only exists in paks below"
    end
    
    H.Report("","on "..v[1][1].." ("..NMSPAKname..")","CONFLICT")
    
    local IsOnlyModScript = true
    for i=1,#v do
      -- H.printf("%-99s: [%s] [%s]",v[i][1],v[i][4],v[i][5])
      IsOnlyModScript = ShowInfo(v[i],luaEntries)
    end

    if IsOnlyModScript then
      H.Report("","IGNORE this conflict IF the scripts <DO NOT CHANGE> the exact SAME VALUES","     >>>")
    end
    
    H.Report("")
  end
  
  local doneIn = ""
  if not IsCalledFromCheckConflictsInMODS then
    doneIn = " in "..H.dClock(os.clock() - sTime)
  end

  if conflictCount > 0 then
    print(strformat(H._zWHITEonDARKCYAN.."    Conflict detection done"..doneIn..", found "..H._zBLACKonYELLOW.." %d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ conflict(s) in GAMEDATA\MODS ]]..H._zDEFAULT,conflictCount))
    print(H._zWHITEonDARKCYAN.."       See "..H._zDEFAULT..H._zBLACKonYELLOW.." REPORT.lua "..H._zDEFAULT..H._zWHITEonDARKCYAN.." for the full list of conflict(s)              "..H._zDEFAULT)
  else
    print(H._zBRIGHTGREEN.."    Conflict detection done"..doneIn..", "..H._zBLACKonYELLOW.." NO conflict "..H._zDEFAULT..H._zBRIGHTGREEN..[[ found in GAMEDATA\MODS]]..H._zDEFAULT)
    H.Report("",[[<<< NO conflict to report in GAMEDATA\MODS >>>]])
  end

  H.Report("","============================ DONE CONFLICTS CHECKING ===================================}")

  -- MBINname[#MBINname][1] = "MBIN(and other NMS files) or script or .txt name"
  -- MBINname[#MBINname][4] = "SCRIPTname"
  -- MBINname[#MBINname][2] = "upper SCRIPTname"
  -- MBINname[#MBINname][5] = "userPAKname"
  -- MBINname[#MBINname][3] = "upper userPAKname"
  -- MBINname[#MBINname][6] = combine #
  
  if conflictCount > 0 then
    H.Report("")
    H.Report("","============== 'BASED on ABOVE conflicts', COMBINE GROUPS are =================={")
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
    -- end -- for i=1,#pakList do
  end -- if conflictCount > 0 then
  
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
          H.Report("",[[:]],"GROUP #"..group)
          IsFirst = false
        end
        
        local luaName = luaEntries[strsub(MBINname[j][3],2,-2)] or "script UNKNOWN"
        local info = MBINname[j][5].." ["..luaName.."]"
        
        -- record this pak done to prevent duplicates
        if not donePakList[MBINname[j][5]] then
          H.Report("","\t- "..info,"     >>>")
          donePakList[MBINname[j][5]] = true
        end
        IsGroupFound = true
      end
    end
    
    H.Report("")
    group = group + 1
    
    -- if index <= #MBINname then
      -- H.printf("==================================================================================   %d %d %s",index,MBINname[index][6],MBINname[index][5])
    -- end
  until not IsGroupFound
  
  -- H.Report("")
  H.Report("","============================ DONE ===================================}\n}")

  -- local IsBadcaseExtension = false
  -- for i=1,#MBINname do
    -- local s = MBINname[i][5]
    -- if s:upper():find(".PAK",1,true) then
      -- local pos,posEnd = s:upper():find(".PAK",1,true)
      -- if s:sub(pos,posEnd) ~= ".pak" then
        -- IsBadcaseExtension = true
        -- H.Report("",s.." extension is NOT lowercase, NMS will not use it!","NOTICE")
        -- for j=i+1,#MBINname do
          -- if MBINname[j][5]:upper() == s:upper() then
            -- -- remove duplicate
            -- MBINname[j][5] = ""
          -- end
        -- end
      -- end
    -- end
  -- end
  -- if IsBadcaseExtension then
    -- print(">>> "..H.gcNOTICE.." [NOTICE] Some mod .pak extensions are UPPERCASE in GAMEDATA\\MODS folder, NMS will NOT USE those mods!!"..H._zDEFAULT)
  -- end
  
end

print()

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
