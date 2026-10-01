local version = "1.1.0"

local print = print
local print1 = print
local print2 = print

local verboseLevel = arg[1]
-- verboseLevel:
--  -v0 == just essential info
--  -v1 == more info
--  -v2 == all DEBUG info

if verboseLevel == "-v0" then
  print1 = function() end
  print2 = function() end
elseif verboseLevel == "-v1" then
  print2 = function() end
end

dofile([[LoadHelpers.lua]])

print1("THIS file (arg[0]) = "..tostring(arg[0]).." v"..version)
print1()

print1("Arguments passed to THIS script = "..tostring(#arg - 1))

local fileList = {}
if arg[2] == nil then
  print("? No file to process")
  return
else
  for i=2,#arg do
    if H.IsDirExist(arg[i]) then
      -- print("Detected folder: ["..arg[i].."]")
      filelist = H.ListDir(fileList,arg[i],false,true)
    else
      fileList[#fileList+1] = arg[i]
    end
  end
end

print("  ============= UPDATING NAMEHASH in EXML FILES =============")
print("Files to process = "..tostring(#fileList))
for i=1,#fileList do
  H.printf("      %3d: [%s]",i,fileList[i])
end

local startTime = os.clock()
for i=1,#fileList do
  print()
  print("  =============")
  print(string.format("  Processing file #%d: %s",i,tostring(fileList[i])))
  print1()

  local content = H.ParseTextFileIntoTable(fileList[i])
  
  -- skip over header
  local k =0
  for j=1,#content do
    if string.find(content[j],"<Data",1,true) then
      k = j
      break
    end
  end
  
  if content[k] == nil then
    -- bad source
    content = {} -- force skipping this file
  end


  local count = 0
  if #content > 0 then
    for j=1,#content do
      local line = content[j]:upper()
      local posA = string.find(line,[["NAMEHASH"]],1,true)
      if posA then
        if j > 1 then
          local tmpName = content[j-1]:upper()
          if string.find(tmpName,[[NAME="NAME"]],1,true) then
            local posB = string.find(tmpName,[[VALUE="]],1,true)
            if posB then
              local nameHash = H.GNH(string.sub(content[j-1],posB+7,string.find(content[j-1],[[" />]],1,true)-1))
              content[j] = string.sub(content[j],1,posA)..[[NameHash" value="]]..nameHash..[[" />]]
              count = count + 1
            end
          end
        else
          --there is no preceding line, cannot use it
        end
      end
    end
    print(string.format("  ==> %d NameHash updates",count))
    if count == 0 then
      H.printf("===>> File #%d NOT saved",i)
    end
  else
    print("? File is empty or Bad source file")
  end
  
  if #content > 0 and count > 0 then
    local destinationFolder = [[..\TOOLS\]]..[[NameHashUpdated]]
    H.mkdir(destinationFolder)
    
    local tmp = table.concat(content,"\n")
    local savePath = destinationFolder..[[\]]..H.GetFilenameFromFilePath(fileList[i])

    if H.IsFileExist(savePath) then
      H.DeleteFile(savePath)
    end

    print()
    print(string.format("===>> Saved UPDATED file #%d to ["..savePath.."]",i))
    H.WriteToFile(tmp,savePath)
  end
  
end -- for i=1,#fileList do

print()
print("   >>> ALL done in: "..H.dClock(os.clock() - startTime))
