--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER
--arg[3] == name of process

IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end
H.pv(">>>     In DiffTime.lua")
H.gfilePATH = arg[1] --for Report()
THIS = "In DiffTime: "

function SecondsToHHMMSS(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00"
  else
    hours = string.format("%02.f", math.floor(seconds/3600))
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
    return hours..":"..mins..":"..secs
  end
end

local DiffTimeTable = H.ParseTextFileIntoTable(arg[2]..[[Times.txt]])
if #DiffTimeTable >= 2 then
  local say = SecondsToHHMMSS(os.difftime(DiffTimeTable[#DiffTimeTable],DiffTimeTable[1]))
  print("\n ===>>> TOTAL TIME to complete: "..say.." "..arg[3].."\n")
  H.Report("","TOTAL TIME to complete: "..say.." "..arg[3])
else
  print("\n ===>>> TOTAL TIME to complete: unknown "..arg[3].."\n")
  H.Report("","TOTAL TIME to complete: unknown "..arg[3])
end

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
