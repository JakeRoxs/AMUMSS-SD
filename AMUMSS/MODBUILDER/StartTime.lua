--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER
--arg[3] == prompt string

IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end
H.pv(">>>     In StartTime.lua")
H.gfilePATH = arg[1] --for Report()
THIS = "In StartTime: "

local startTime = os.time()
H.WriteToFile(startTime.."\n",arg[2]..[[Times.txt]])
-- print()

local promptString = arg[3] or "AMUMSS"

print("   "..H._zBRIGHTGREEN.."=== "..H._zDEFAULT.."Started "..promptString.." "..H._zBRIGHTGREEN.."automatic"..H._zDEFAULT.." processing at "..H.ShowTime(startTime)..H._zBRIGHTGREEN.." ==="..H._zDEFAULT)
H.Report("","Started "..promptString.." automatic processing at "..H.ShowTime(startTime).." {")
H.Report("")

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
