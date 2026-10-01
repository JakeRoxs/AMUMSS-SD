--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER
--arg[3] == "1" (check NMS MODS for conflict)
--arg[4] == "1" (called by UPDATED batch)

if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
H.pv(">>>     In CheckREPORTLOG.lua")
H.gfilePATH = arg[1] --to use by LoadHelpers.H.Report()
THIS = "In CheckREPORTLOG: "

  -- os.execute([[powershell.exe "[console]::beep(1109,200)"; "[console]::beep(261,800)"]])

local IsVerboseFinalREPORT = os.getenv("-VerboseFinalREPORT") == "Y"

-- print("arg[3] = ["..arg[3].."]")
local CheckMODSconflicts = (arg[3] == "1") or (arg[3] == "3")
local CheckSCRIPTconflicts = (arg[3] == "1") or (arg[3] == "4")

local LogTable = H.ParseTextFileIntoTable(arg[1]..[[REPORT.lua]])
 
local NoticeCount = 0
local WarningCount = 0
local ConflictCount = 0
local ErrorCount = 0
local BugCount = 0

local Notice = {}
local Warning = {}
local Error = {}

local scriptName = ""
local scriptCount = 0
local IsFoundFirstScript = false

for i=1,#LogTable do
  if string.find(LogTable[i],"Extracting ALL files from:",1,true) then
    scriptName = string.sub(string.gsub(LogTable[i],"Extracting ALL files from: ",""),1,-1)
    -- scriptCount = scriptCount + 1
  end
  
  if string.find(LogTable[i],"Starting to process script",1,true) then
    scriptName = string.sub(string.gsub(LogTable[i],"Starting to process script #",""),1,-3)
    scriptCount = scriptCount + 1
    IsFoundFirstScript = true
  end

  if IsFoundFirstScript then
    if string.find(LogTable[i],"Processing sub-script",1,true) then
      local pos1 = string.find(LogTable[i],"[[",1,true)
      local pos2 = string.find(LogTable[i],"]]",1,true)
      scriptName = string.sub(LogTable[i],pos1+2,pos2-1)
      scriptCount = scriptCount + 1
    end

    if string.find(LogTable[i],"[[NOTICE]]",1,true) then
      NoticeCount = NoticeCount + 1
      if Notice[scriptName] then
        Notice[scriptName] = Notice[scriptName] + 1
      else
        Notice[scriptName] = 1
      end
    end

    if string.find(LogTable[i],"[[WARNING]]",1,true) then
      WarningCount = WarningCount + 1
      if Warning[scriptName] then
        Warning[scriptName] = Warning[scriptName] + 1
      else
        Warning[scriptName] = 1
      end
    end

    if string.find(LogTable[i],"[[ERROR]]",1,true) then
      ErrorCount = ErrorCount + 1
      if Error[scriptName] then
        Error[scriptName] = Error[scriptName] + 1
      else
        Error[scriptName] = 1
      end
    end

    if string.find(LogTable[i],"[[CONFLICT]]",1,true) then
      ConflictCount = ConflictCount + 1
    end

    if string.find(LogTable[i],"[[BUG]]",1,true) then
      BugCount = BugCount + 1
    end
  end
end

local function stripBracket(say)
  say = string.gsub(say,"%[%[","[")
  say = string.gsub(say,"%]%]","]")
  return say
end

local say = ""
local spacerCMD = "            "
local spacerREPORT = "         "
local msgType = "ATTENTION"
local SeeReport = "" -- [[   >>> See "REPORT.lua"  <<<]]

local countSize = 1
if scriptCount < 10 then
  countSize = 1
elseif scriptCount < 100 then
  countSize = 2
elseif scriptCount < 1000 then
  countSize = 3
elseif scriptCount < 10000 then
  countSize = 4
end

-- BUG
if BugCount > 0 then
  -- if BugCount > 1 then
    -- say = string.format([=[%6u [[BUG]]s reported. PLEASE post both "log.lua" and "REPORT.lua" on Discord:  https://discord.gg/HFjnmnwe67]=],BugCount)
  -- else
    say = string.format([=[%6u [[BUG]] reported. PLEASE post both "log.lua" and "REPORT.lua" on Discord:  https://discord.gg/HFjnmnwe67]=],BugCount)
  -- end
  H.Report("")
  H.Report("",say,msgType)

  -- if BugCount > 1 then
    -- say = string.format(" %6u [["..H.gcERROR.."BUG"..H._zDEFAULT..[=[]]s reported. PLEASE post both "log.lua" and "REPORT.lua" on Discord:  https://discord.gg/HFjnmnwe67]=],BugCount)
  -- else
    say = string.format(" %6u [["..H.gcERROR.."BUG"..H._zDEFAULT..[=[]] reported. PLEASE post both "log.lua" and "REPORT.lua" on Discord:  https://discord.gg/HFjnmnwe67]=],BugCount)
  -- end
  print("")
  print(stripBracket(say))
  
  os.execute([[powershell.exe "[console]::beep(1109,200)"; "[console]::beep(261,800)"]])
  -- beep(1200,100)
  -- beep(500,500)
end

-- ERROR
if ErrorCount > 0 then
  -- if ErrorCount > 1 then
    -- say = string.format([=[%6u [[ERROR]]s detected]=],ErrorCount)
  -- else
    say = string.format([=[%6u [[ERROR]] detected]=],ErrorCount)
  -- end
  H.Report("")
  H.Report("",say,msgType)

  if IsVerboseFinalREPORT then
    for k,v in pairs(Error) do
      -- H.printf("[%s] = [%s]",tostring(k),tostring(v))
      if string.find(k,"/",1,true) then
        local scriptPos = string.sub(k,1,string.find(k,"/",1,true)-1)

        while #scriptPos < countSize do
          scriptPos = " "..scriptPos
        end
        local scriptName = string.sub(k,string.find(k,"/",1,true),-1)
        H.Report("",string.format("#%s%s [%d]",scriptPos,scriptName,v),"      >>>")

      else
        H.Report("",string.format("%s%s [%d]","In MOD: ",k,v),"      >>>")
      end
      
    end
  end
  
  -- if ErrorCount > 1 then
    -- say = string.format(" %6u [["..H.gcERROR.."ERROR"..H._zDEFAULT.."]]s detected",ErrorCount)
  -- else
    say = string.format(" %6u [["..H.gcERROR.."ERROR"..H._zDEFAULT.."]] detected",ErrorCount)
  -- end
  print("")
  print(stripBracket(say)..SeeReport)

  say = spacerCMD.."ERRORS will NOT produce MBIN files and a complete MOD file may not have been created."
  print(say)
  H.Report("",say,msgType)
  say = spacerCMD.."You need to correct the error first!"
  print(say)
  H.Report("",say,msgType)
else
  say = string.format("%6u [[ERROR]] detected",ErrorCount)
  H.Report("")
  H.Report("",spacerREPORT..say)

  say = string.format("%s %6u [[ERROR]] detected %s",H._zBRIGHTGREEN,ErrorCount,H._zDEFAULT)
  print("")
  print(stripBracket(say))
end

-- WARNING
if WarningCount > 0 then
  -- if WarningCount > 1 then
    -- say = string.format("%6u [[WARNING]]s raised",WarningCount)
  -- else
    say = string.format("%6u [[WARNING]] raised",WarningCount)
  -- end
  H.Report("")
  H.Report("",say,msgType)
  
  if IsVerboseFinalREPORT then
    for k,v in pairs(Warning) do
      if string.find(k,"/",1,true) then
        local scriptPos = string.sub(k,1,string.find(k,"/",1,true)-1)

        while #scriptPos < countSize do
          scriptPos = " "..scriptPos
        end
        local scriptName = string.sub(k,string.find(k,"/",1,true),-1)
        H.Report("",string.format("#%s%s [%d]",scriptPos,scriptName,v),"      >>>")

      else
        H.Report("",string.format("%s%s [%d]","In MOD: ",k,v),"      >>>")
      end
      
    end
  end
  
  -- if WarningCount > 1 then
    -- say = string.format(" %6u [["..H.gcWARNING.."WARNING"..H._zDEFAULT.."]]s raised",WarningCount)
  -- else
    say = string.format(" %6u [["..H.gcWARNING.."WARNING"..H._zDEFAULT.."]] raised",WarningCount)
  -- end
  print("")
  print(stripBracket(say)..SeeReport)

  say = spacerCMD.."WARNINGS may produce good or bad MOD files.  You have to be the judge!"
  print(say)
  H.Report("",say,msgType)
else
  say = string.format("%6u [[WARNING]] raised",WarningCount)
  H.Report("")
  H.Report("",spacerREPORT..say)

  say = string.format("%s %6u [[WARNING]] raised %s",H._zBRIGHTGREEN,WarningCount,H._zDEFAULT)
  print("")
  print(stripBracket(say))
end

-- NOTICE
if NoticeCount > 0 then
  -- if NoticeCount > 1 then
    -- say = string.format("%6u [[NOTICE]]s raised",NoticeCount)
  -- else
    say = string.format("%6u [[NOTICE]] raised",NoticeCount)
  -- end
  H.Report("")
  H.Report("",say,msgType)

  if IsVerboseFinalREPORT then
    for k,v in pairs(Notice) do
-- H.printf("%s %s",k,v)
      local scriptPos = k
      local scriptName = k
      local pos = string.find(k,"/",1,true)
      if pos then
        scriptPos = string.sub(k,1,pos-1)
        scriptName = string.sub(k,pos,-1)
      end
      while #scriptPos < countSize do
        scriptPos = " "..scriptPos
      end
      -- local scriptName = string.sub(k,pos,-1)
-- H.printf("%s %s",k,v)
      H.Report("",string.format("#%s%s [%d]",scriptPos,scriptName,v),"      >>>")
    end
  end
  
  -- if NoticeCount > 1 then
    -- say = string.format(" %6u [["..H.gcNOTICE.."NOTICE"..H._zDEFAULT.."]]s raised",NoticeCount)
  -- else
    say = string.format(" %6u [["..H.gcNOTICE.."NOTICE"..H._zDEFAULT.."]] raised",NoticeCount)
  -- end
  print("")
  print(stripBracket(say)..SeeReport)

  say = spacerCMD.."NOTICES produce good MOD files but alert you to something."
  print(say)
  H.Report("",say,msgType)
else
  say = string.format("%6u [[NOTICE]] raised",NoticeCount)
  H.Report("")
  H.Report("",spacerREPORT..say)
  
  say = string.format("%s %6u [[NOTICE]] raised %s",H._zBRIGHTGREEN,NoticeCount,H._zDEFAULT)
  print("")
  print(stripBracket(say))
end

print("")
-- H.Report("")

-- CONFLICT
if CheckMODSconflicts or CheckSCRIPTconflicts then
  if ConflictCount > 0 then
    if CheckMODSconflicts and CheckSCRIPTconflicts then
      -- if ConflictCount > 1 then
        -- say = string.format("%6u [[CONFLICT]]s detected in processed Scripts/MODs",ConflictCount)
      -- else
        say = string.format("%6u [[CONFLICT]] detected in processed Scripts/MODs",ConflictCount)
      -- end
      H.Report("")
      H.Report("",say,msgType)

      -- say = string.format([=[%6u [[CONFLICT]] detected in processed Scripts/MODs]=],ConflictCount)
      -- -- print("")
      -- H.Report("")
      -- H.Report("",spacerREPORT..say)  
      
      -- if ConflictCount > 1 then
        -- say = string.format(" %6u [[%sCONFLICT%s]]s detected in processed Scripts/MODs",ConflictCount,H.gcATTENTION,H._zDEFAULT)
      -- else
        say = string.format(" %6u [[%sCONFLICT%s]] detected in processed Scripts/MODs",ConflictCount,H.gcATTENTION,H._zDEFAULT)
      -- end
      print(stripBracket(say)..SeeReport)

      -- print(stripBracket(say))

    elseif CheckMODSconflicts then
      -- if ConflictCount > 1 then
        -- say = string.format("%6u [[CONFLICT]]s detected in processed PCBANKS/MODS MODs",ConflictCount)
      -- else
        say = string.format("%6u [[CONFLICT]] detected in processed GAMEDATA/MODS",ConflictCount)
      -- end
      H.Report("")
      H.Report("",say,msgType)

      -- say = string.format([=[%6u [[CONFLICT]] detected in processed MODS MODs]=],ConflictCount)
      -- -- print("")
      -- H.Report("")
      -- H.Report("",spacerREPORT..say)
      
      -- if ConflictCount > 1 then
        -- say = string.format(" %6u [[%sCONFLICT%s]]s detected in processed PCBANKS/MODS MODs",ConflictCount,H.gcATTENTION,H._zDEFAULT)
      -- else
        say = string.format(" %6u [[%sCONFLICT%s]] detected in processed GAMEDATA/MODS",ConflictCount,H.gcATTENTION,H._zDEFAULT)
      -- end
      print(stripBracket(say)..SeeReport)

      -- print(stripBracket(say))
    
    else --only SCRIPTS
      -- if ConflictCount > 1 then
        -- say = string.format("%6u [[CONFLICT]]s detected in processed SCRIPTS",ConflictCount)
      -- else
        say = string.format("%6u [[CONFLICT]] detected in processed SCRIPTS",ConflictCount)
      -- end
      H.Report("")
      H.Report("",say,msgType)

      -- say = string.format([=[%6u [[CONFLICT]] detected in processed SCRIPTS]=],ConflictCount)
      -- -- print("")
      -- H.Report("")
      -- H.Report("",spacerREPORT..say)  

      -- if ConflictCount > 1 then
        -- say = string.format(" %6u [[%sCONFLICT%s]]s detected in processed SCRIPTS",ConflictCount,H.gcATTENTION,H._zDEFAULT)
      -- else
        say = string.format(" %6u [[%sCONFLICT%s]] detected in processed SCRIPTS",ConflictCount,H.gcATTENTION,H._zDEFAULT)
      -- end
      print(stripBracket(say)..SeeReport)

      -- print(stripBracket(say))
    end

    -- H.Report("")
    say = spacerCMD.."CONFLICTS will prevent the mods involved from expressing their full effect."
    print(say)
    H.Report("",say,msgType)

    say = spacerCMD.."Some CONFLICTS can be resolved by COMBINING mods..."
    print(say)
    H.Report("",say,msgType)
    -- print()
    -- H.Report("")

    say = spacerCMD.."See file 'README/README-Creating_a_Patch_for_existing_MODs.txt' for further help"
    print(say)
    H.Report("",say,msgType)
    print("")
    H.Report("")
    
  else
    -- if arg[4] ~= "1" and not io.open(arg[2].."OnlyOneScript.txt") then
      -- say = spacerCMD.."It is safe to use together any of the generated MODs"
      -- print(say)
      -- H.Report("",spacerREPORT..say)
    -- end
      
  end
  
else
  say = "     - CONFLICT Detection Skipped at user request"
  H.Report("")
  H.Report("",spacerREPORT..say)  

  say = string.format("     %s - CONFLICT Detection Skipped at user request %s",H._zBRIGHTGREEN,H._zDEFAULT)
  print(say)
end

print("")
H.Report("")

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
