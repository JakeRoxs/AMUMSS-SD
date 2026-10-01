--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER

IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end
H.pv(">>>     In CreateContentList.lua")
H.gfilePATH = arg[1] --for Report()

local ModFilename = H.LoadFileData(arg[2]..[[MOD_FILENAME.txt]])
H.WriteToFile("This mod ("..ModFilename..") contains:".."\n\n",arg[2]..[[Content.txt]])

local ScriptNameTable = H.ParseTextFileIntoTable(arg[2]..[[CONTENT_LIST.txt]])

for i=1,#ScriptNameTable do
  -- local 
  -- H.WriteToFileAppend("- "..ScriptName.."\n",arg[2]..[[Content.txt]])
  H.WriteToFileAppend("- "..ScriptNameTable[i].."\n",arg[2]..[[Content.txt]])
  break
end
