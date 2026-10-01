-- we are in AMUMSS

if H == nil then dofile([[.\MODBUILDER\LoadHelpers.lua]]) end
-- H.pv(">>>     In CopyREPORT.lua")
-- THIS = "In CopyREPORT: "

-- H.Report_flush(false,THIS)

-- copy REPORT.lua to TOOLS\REPORTS_BACKUP
-- date format for REPORTS
local now = os.date("%Y%m%d-%H%M%S")

local cleanedNowREPORT = now:gsub([[/]],[[]]):gsub([[\]],[[]]):gsub([[:]],[[]]):gsub([[*]],[[]]):gsub([[?]],[[]]):gsub([["]],[[]]):gsub([[<]],[[]]):gsub([[>]],[[]]):gsub([[|]],[[]])

H.CopyFile([[.\REPORT.lua]], [[.\TOOLS\REPORTS_BACKUP\REPORT_]]..cleanedNowREPORT..[[.lua*]], H.paramFiles) --, false
-- END: copy REPORT.lua to TOOLS\REPORTS_BACKUP

-- H.LuaEndedOk(THIS)
