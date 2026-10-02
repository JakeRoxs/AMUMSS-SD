-- Run only in an isolated writable fixture directory, never a game directory.
local builder = assert(arg[1], "MODBUILDER path required")
local scratch = assert(arg[2], "Scratch directory required")
local fs = require("lfs")
assert(fs.chdir(scratch))
scratch = fs.currentdir()
assert(fs.chdir(builder))
package.path = builder.."/?.lua;"..package.path
dofile(builder.."/LoadHelpers.lua")
assert(H.GetFolderPathFromFilePath("MODELS/PLANETS/CREATURES/test.MXML") == [=[MODELS\PLANETS\CREATURES]=])
local dir = scratch.."/files (test)'quoted"
H.mkdir(dir.."/nested")
assert(H.IsDirExist(dir:gsub("/", [=[\]=])))
local file = dir.."/nested/test.MXML"
H.WriteToFile("fixture\n", file:gsub("/", [=[\]=]))
assert(H.IsFileExist(file:gsub("/", [=[\]=])))
assert(H.LoadFileData((file:gsub("/", [=[\]=]))) == "fixture\n")
H.WriteToFile("binary fixture", dir.."/nested/test.MBIN", "b")
assert(H.CopyFile(file, scratch.."/copy/test.MXML*", H.paramFiles))
assert(H.IsFileExist(scratch.."/copy/test.MXML"))
assert(H.CopyFile(dir, scratch.."/output/", H.paramExcMXML, false))
assert(H.IsFileExist(scratch.."/output/nested/test.MBIN"))
assert(not H.IsFileExist(scratch.."/output/nested/test.MXML"))
H.DeleteFile(dir:gsub("/", [=[\]=])..[=[\*.MXML]=])
assert(not H.IsFileExist(file))
assert(H.IsFileExist(dir.."/nested/test.MBIN"))
assert(not pcall(H.WriteToFile, "bad", scratch.."/missing/fail.txt"))

-- A quiet compiler failure must not be reported as successful decompilation.
local originalPopen, originalExecute = io.popen, os.execute
H.GetMBINCompilerVersion = function() return "7.4.1.3", 7.040103 end
os.execute = function() return true end
local command
io.popen = function(cmd)
  command = cmd
  return {read = function() return "" end, close = function() return nil, "exit", 7 end}
end
assert(H.MBINCompiler_D([=[.\custom folder]=], false, false, true) ~= "OK")
assert(command:find("./custom folder", 1, true))
io.popen, os.execute = originalPopen, originalExecute
H.DeleteDir(dir)
H.DeleteDir(dir) -- Missing directory is harmless.
print("Native file operations passed: mixed paths, nested writes, copy exclusions, compiler failure")
