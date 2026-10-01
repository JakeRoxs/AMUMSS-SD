-- ****************************************************
-- main
-- ****************************************************

--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER

if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
H.pv(">>>     In CheckGlobalReplacements.lua")
H.gfilePATH = arg[1] --used by LoadHelpers.Report()
THIS = "In CheckGlobalReplacements: "

local ReportTable = H.ParseTextFileIntoTable(arg[1]..[[REPORT.lua]])

local logTable
if H.IsFileExist(arg[1]..[[log.lua]]) then
  logTable = H.ParseTextFileIntoTable(arg[1]..[[log.lua]])
else
  logTable = H.ParseTextFileIntoTable(arg[1]..[[log.txt]])
end

local numSpaces = 5

local Archived = {}
local IsFound = false
local numFilesArchived = ""
for j=1,#logTable do
  local line = logTable[j]
  if string.find(line,"Total Files Archived",1,true) then
    -- print("Archived")
    local info = H.ltrim(string.sub(line,1,string.find(line,":",1,true)-1))
    local spacer = numSpaces - #info
    info = string.rep(" ",spacer)..info
    numFilesArchived = info
    IsFound = true
  end
  if IsFound and (string.find(line,"Ended script ",1,true) or string.find(line,"Ended sub-script",1,true)) then
    local ScriptName = H.StripInfo(line," [","]")
    Archived[ScriptName] = numFilesArchived
    numFilesArchived = ""
    IsFound = false
  end
end

-- H.DprintTable(Archived)

local ScriptName = ""
local SubScriptName = ""
local ScriptProcessedCount = 0
local SubScriptProcessedCount = 0
local SubScriptGlobalPos = 0
local ActionCount = -1
local ScriptCount = -1
local UsesGLOBAL = ""
local reportUnknown = false
local reportBack = false
local bugFound = false
local numFilesArchived = ""

local NoProblems = true
H.Report("")
print()
for i=1,#ReportTable do
  local line = ReportTable[i]
  if line then
    if string.find(line,"[[BUG]]",1,true) then
      bugFound = true
      break
    end
    
    if string.find(line,"Starting to process script",1,true) then
      reportUnknown = false
      ScriptName = H.StripInfo(line," [[","]]")
      ScriptProcessedCount = ScriptProcessedCount + 1
      SubScriptProcessedCount = 0 -- reset
      SubScriptGlobalPos = 0 -- reset
    end
    
    if string.find(line,"Processing sub-script",1,true) then
      reportUnknown = false
      ScriptName = H.StripInfo(line," [[","]]")
      ScriptProcessedCount = ScriptProcessedCount + 1
      SubScriptProcessedCount = SubScriptProcessedCount + 1
    end
    
    if string.find(line,"Still processing script",1,true) then
      ScriptProcessedCount = ScriptProcessedCount - 1 -- not in a new script, this is a multi-script
    end
    
    if string.find(line,"Ended script processing with",1,true) then
      reportUnknown = false
      if ActionCount < 0 then ActionCount = 0 end
      ActionCount = ActionCount + tonumber(H.StripInfo(line," [["," action"))
      ActionCount = ActionCount + tonumber(H.StripInfo(line,", "," files"))
    end

    if string.find(line,"Ended script [",1,true) or string.find(line,"Ended sub-script",1,true) then
      reportBack = true
      if ActionCount < 0 then
        reportUnknown = true
      end
    end

    if string.find(line,"[ENDED THIS SCRIPT PROCESSING]",1,true) then
      reportUnknown = true
    end

    if string.find(line,".GLOBAL.MXML ",1,true) or string.find(line,"GLOBALS.MXML ",1,true) then
      if string.find(line,"Getting ",1,true) and string.find(line,".MXML ",1,true) then
        UsesGLOBAL = " ["..string.sub(line,string.find(line,"Getting ",1,true)+8,string.find(line,".MXML ",1,true)+4).."]"
      end
    end
  end
  
  if ScriptName ~= "" then
    -- print("ScriptName: "..ScriptName)
    -- print("#logTable: "..#logTable)
    
    if Archived[ScriptName] then
      numFilesArchived = Archived[ScriptName].." archived"
    else
      numFilesArchived = string.rep(" ",numSpaces - 2).."-- archived"
    end
    
    if ActionCount >= 0 and reportBack then
      local ScriptTable = H.ParseTextFileIntoTable(arg[1]..[[ModScript\]]..ScriptName)
      
      for j=SubScriptGlobalPos + 1,#ScriptTable do
        local line = ScriptTable[j]
        if line and string.find(line,"global replacement",1,true) then
          ScriptCount = tonumber(H.StripInfo(line,"--"," global"))
          if ScriptCount == nil then
            ScriptCount = -1
          elseif SubScriptProcessedCount > 0 then
            SubScriptGlobalPos = j
          end
          break
        end
      end
      
      local state = "ERROR"
      if ScriptCount == ActionCount then
        state = "INFO"
      elseif ScriptCount == -1 then
        state = "WARNING"
      end
      
      if state ~= "INFO" then
        NoProblems = false
      end
      
      -- always report
      if SubScriptProcessedCount == 0 then
        H.Report("",string.rep(" ",7-#state)..string.format("[%s] %3d: %5d global replacements / %5d action(s)%s: %s%s",state,ScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
        print(string.rep(" ",7-#state)..string.format("[%s] %3d: %5d global replacements / %5d action(s)%s: %s%s",state,ScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
      else
        H.Report("",string.rep(" ",7-#state)..string.format("[%s] %3d.%d: %5d global replacements / %5d action(s)%s: %s%s",state,ScriptProcessedCount,SubScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
        print(string.rep(" ",7-#state)..string.format("[%s] %3d.%d: %5d global replacements / %5d action(s)%s: %s%s",state,ScriptProcessedCount,SubScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
      end
      
      --reset for next script
      ScriptName = ""
      ActionCount = -1
      ScriptCount = -1
      UsesGLOBAL = ""

    elseif reportUnknown then
      reportUnknown = false
      NoProblems = false

      if ActionCount == -1 then
        msg = "NOTICE"
      else
        msg = "UNKNOWN"
      end

      if SubScriptProcessedCount == 0 then
        H.Report("",string.rep(" ",7-string.len("UNKNOWN"))..string.format("[%s] %3d: %5d global replacements / %5d action(s)%s: %s%s",msg,ScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
        print(string.rep(" ",7-string.len(msg))..string.format("[%s] %3d: %5d global replacements / %5d action(s)%s: %s%s",msg,ScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
      else
        H.Report("",string.rep(" ",7-string.len(msg))..string.format("[%s] %3d.%d: %5d global replacements / %5d action(s): %s%s %s",msg,ScriptProcessedCount,SubScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
        print(string.rep(" ",7-string.len(msg))..string.format("[%s] %3d.%d: %5d global replacements / %5d action(s)%s: %s%s",msg,ScriptProcessedCount,SubScriptProcessedCount,ScriptCount,ActionCount,numFilesArchived,ScriptName,UsesGLOBAL))
      end
    end
  end
end

if bugFound then
  H.Report("","ALL scripts: BUG found!")
  print("ALL scripts: "..H._zBRIGHTRED.."BUG found!"..H._zDEFAULT)
else
  if NoProblems and #ReportTable > 0 then
    H.Report("","ALL scripts: 'Suggested Global Replacements numbers' are MATCHING!")
    print("ALL scripts: 'Suggested Global Replacements numbers' are "..H._zBRIGHTGREEN.."MATCHING!"..H._zDEFAULT)
  end
end

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
