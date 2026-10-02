-- Run with the private native runtime; do not execute a downloaded mod or build.
local builder = assert(arg[1], "MODBUILDER path required")
local fixture = assert(arg[2], "Existing read-only fixture path required")
assert(lfs == nil, "Probe expects a fresh Lua state without preloaded lfs")
local filesystem = require("lfs")
assert(filesystem.chdir(builder))
package.path = builder .. "/?.lua;" .. package.path

local function blocked(operation)
  return function() error("Helper probe blocked " .. operation) end
end
os.execute = blocked("subprocess execution")
io.popen = blocked("subprocess capture")
os.rename = blocked("rename")
os.exit = blocked("exit")
os.remove = function() return nil, "Helper probe does not remove files" end
local original_open = io.open
io.open = function(path, mode)
  mode = mode or "r"
  assert(not mode:find("[wa+]"), "Helper probe blocked file write")
  return original_open(path, mode)
end
debug.sethook(function() error("Helper probe instruction limit") end, "", 10000000)
dofile(builder .. "/LoadHelpers.lua")
debug.sethook()

assert(H.GetLargeHex("18446744073709551615") == "FFFFFFFFFFFFFFFF")
assert(H.GetLargeHex("9223372036854775808") == "8000000000000000")
assert(H.IsFileExist(fixture))
assert(#H.LoadFileData(fixture) > 0)
local worker = H.lanes.gen("*", function()
  local integer = require("bint")(256)
  local fs = require("lfs")
  return tostring(integer(21) + integer(21)), fs.currentdir()
end)()
assert(worker[1] == "42")
assert(worker[2] == lfs.currentdir())
print("AMUMSS helper module integration passed: large seeds, file reads, threaded module loading")
print("Full processor build not executed; native path/process portability remains outstanding")
