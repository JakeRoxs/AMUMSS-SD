-- The implementation and license are maintained in the pinned upstream submodule.
local source = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/")
local directory = source:match("^(.*[/])") or "./"
local chunk, failure = loadfile(directory .. "../../third_party/lua-bint/bint.lua")
assert(chunk, "Missing upstream bint; run git submodule update --init --recursive: " .. tostring(failure))
return chunk()
