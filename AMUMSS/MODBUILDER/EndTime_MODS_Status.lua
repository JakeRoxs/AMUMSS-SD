--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER

IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end
H.pv(">>>     In EndTime_MODS_Status.lua")
H.gfilePATH = arg[1] --for Report()
THIS = "In EndTime_MODS_Status: "

local endTime = os.time()
H.WriteToFileAppend(endTime.."\n",arg[2]..[[Times.txt]])
-- H.Report("","Ended automatic processing at "..H.ShowTime(endTime))
-- H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
