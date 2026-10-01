-- SLOWER
-- based on monkeyman192 python script namehash.py
function GetNameHash(name)
  local n = {string.byte(string.upper(name),1,#name)} 
  local i = 0

  for j=1,#n do
    k = (1025 * (i + n[i])) & 0xffffffff
    j = (k >> 6) & 0xffffffff
    i = (j ~ k) & 0xffffffff -- XOR
  end
  
  y = (9 * i) & 0xffffffff
  w = (y >> 11) & 0xffffffff
  z = 32769 * ( y ~ w ) & 0xffffffff
  return tostring(z)
end

-- FASTER
-- from lyravega https://discord.com/channels/215514623384748034/994078792932929546/1089170105444880504
-- this is based on: https://en.wikipedia.org/wiki/Jenkins_hash_function
---@param inputString string
---@return string hash
local function generateJenkinsHash(inputString)
    local hash, charTable = 0, {string.byte(inputString:upper(), 1, #inputString)}

    for i = 1, #inputString do
        hash = (hash + charTable[i]) & 0xffffffff
        hash = (hash + (hash << 10)) & 0xffffffff
        hash = (hash ~ (hash >> 6)) & 0xffffffff
    end
    hash = (hash + (hash << 3)) & 0xffffffff
    hash = (hash ~ (hash >> 11)) & 0xffffffff
    hash = (hash + (hash << 15)) & 0xffffffff

    return tostring(hash)
end

-- FASTEST
function GNH_for1(name)
    local hash = 0
    local c = {string.byte(name:upper(), 1, #name)}
    for i = 1, #c do
        hash = (hash + c[i]) & 0xffffffff
        hash = (hash + (hash << 10)) & 0xffffffff
        hash = (hash ~ (hash >> 6)) & 0xffffffff
    end
    hash = (hash + (hash << 3)) & 0xffffffff
    hash = (hash ~ (hash >> 11)) & 0xffffffff
    return tostring( (hash + (hash << 15)) & 0xffffffff )
end

-- FASTEST of ALL
function GNH_for2(name)
    local hash,c = 0,{string.byte(name:upper(), 1, #name)}
    for i = 1, #c do
        hash = (hash + c[i]) & 0xffffffff
        hash = (hash + (hash << 10)) & 0xffffffff
        hash = (hash ~ (hash >> 6))-- & 0xffffffff
    end
    hash = (hash + (hash << 3)) & 0xffffffff
    hash = (hash ~ (hash >> 11))-- & 0xffffffff
    return tostring( (hash + (hash << 15)) & 0xffffffff )
end

-- SLOWER than GNH_for
function GNH_while(name)
    local hash = 0
    local c = {string.byte(name:upper(), 1, #name)}
    local i = 0
    while i ~= #c do
        i = i + 1
        hash = (hash + c[i]) & 0xffffffff
        hash = (hash + (hash << 10)) & 0xffffffff
        hash = (hash ~ (hash >> 6)) & 0xffffffff
    end
    hash = (hash + (hash << 3)) & 0xffffffff
    hash = (hash ~ (hash >> 11)) & 0xffffffff
    return tostring( (hash + (hash << 15)) & 0xffffffff )
end

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER

LocalFolder = [[..\]]
if gVerbose == nil then dofile("LoadHelpers.lua") end
print(">>>     In GetNameHash.lua")
THIS = "In GetNameHash: "

THIS = "In GetNameHash: " --Check for THIS in code before changing this string

-- SnapPoint_IndSelf_N, 4086606025
-- IndLarge_In_, 3826015350
-- NullSnap_, 2582035683
-- SnapPoint_IndLargeFloor_1, 801320518
-- IndustrialLargeFloor_In_1, 1344797591
-- SnapPoint_IndFloorQrt_4, 2034711774
-- IndustrialLargeFloor_Out_1, 1272152194
-- SnapPoint_PlanterSmall, 3456283022
-- Planter_Out_2, 3412797611
-- SnapPoint_IndFloorSQrt_1, 1516055932
-- SnapPoint_IndSSelf_E, 3996672075
-- SnapPointIndustrialLarge_W, 3302193811

nameList = ParseTextFileIntoTable("outputHash.csv")
print("#nameList = "..#nameList)
print("")

local count = 0
for i=1,#nameList do
  local n = nameList[i]
  print("")
  print("["..n.."]")
  local name = string.sub(n,1,string.find(n,",",1,true)-1)
  -- print("     name = ["..name.."]")
  local hash = string.sub(n,string.find(n,",",1,true)+2)
  -- print("     hash = ["..hash.."]")
  
  local newHash = GNH_for2(name)
  print("  newHash = ["..newHash.."]")
  
  if newHash ~= hash then
    print("??? hash not matching")
  else
    count = count + 1
    print(">>> hash matching")
  end
end

print("")
print(tostring(count).."/"..#nameList.." matching")
print("")
print("Testing speed...")

for i=1,#nameList do
  local n = nameList[i]
  local name = string.sub(n,1,string.find(n,",",1,true)-1)
  
  -- local time = os.clock()
  -- local count = 0
  -- while count < 1000000 do
    -- local newHash = GetNameHash(name)
    -- count = count + 1
  -- end
  -- print((os.clock()-time).." GetNameHash("..name..")")
  
  -- local time = os.clock()
  -- local count = 0
  -- while count < 1000000 do
    -- local newHash = generateJenkinsHash(name)
    -- count = count + 1
  -- end
  -- print((os.clock()-time).." generateJenkinsHash("..name..")")

  local time = os.clock()
  local count = 0
  while count < 1000000 do
    local newHash = GNH_for1(name)
    count = count + 1
  end
  print((os.clock()-time).." GNH_for1("..name..")")

  local time = os.clock()
  local count = 0
  while count < 1000000 do
    local newHash = GNH_for2(name)
    count = count + 1
  end
  print((os.clock()-time).." GNH_for2("..name..")")

  -- local time = os.clock()
  -- local count = 0
  -- while count < 1000000 do
    -- local newHash = GNH_while(name)
    -- count = count + 1
  -- end
  -- print((os.clock()-time).." GNH_while("..name..")")

  print("===============")
end

-- name = "SnapPoint_IndSelf_N"

-- z = GetNameHash(name)

-- print("")
-- print(name.." = ["..z.."]")
-- if z == "4086606025" then
  -- print("OK")
-- end

LuaEndedOk(THIS)

