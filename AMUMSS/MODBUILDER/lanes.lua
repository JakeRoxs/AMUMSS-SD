-- Native lanes_core must match the pinned upstream wrapper; bootstrap builds both.
local source = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/")
local directory = source:match("^(.*[/])") or "./"
local chunk, failure = loadfile(directory .. "../../third_party/lanes/src/lanes.lua")
assert(chunk, "Missing upstream lanes; run git submodule update --init --recursive: " .. tostring(failure))
return chunk()
