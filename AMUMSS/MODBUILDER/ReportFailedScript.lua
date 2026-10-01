--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER

if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
H.pv(">>>     In ReportFailedScript.lua")
H.gfilePATH = arg[1] --to use by LoadHelpers.Report()
THIS = "In ReportFailedScript: "
--print("@@@ "..lfs.currentdir())

local ModScriptFailed = H.ParseTextFileIntoTable(arg[2].."FailedScriptList.txt")
if #ModScriptFailed > 0 then
  print()
  print(H.gcATTENTION.."[ATTENTION] Failed scripts report:"..H._zDEFAULT)
  -- H.Report("")
  H.Report("","Failed scripts:","ATTENTION")

  for i=1,#ModScriptFailed do
    print("   - "..ModScriptFailed[i])  
    H.Report("","   - "..ModScriptFailed[i],"      >>>")
  end

else
  print()
  print(H._zBRIGHTGREEN..">>> No script failed processing!"..H._zDEFAULT)
  --H.Report("","}")
  H.Report("")
  H.Report("","No script failed processing!")
end

-- H.Report("")
H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
