local version = "1.1.0"
local DEBUG = false

dofile([[LoadHelpers.lua]])

function H.DEBUG_VCTproperty_print() end
gDEBUG_VCTproperty = false
if gDEBUG_VCTproperty then H.DEBUG_VCTproperty_print = H.DEBUG_print end

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

local startTimeTotal = os.clock()

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
      fileList = H.ListDir(fileList,arg[i],false,true)
    else
      if H.IsFileExist(arg[i]) then
        fileList[#fileList+1] = arg[i]
      end
    end
  end
end

print("  ============= Get TREE =============")
print("Files to process = "..tostring(#fileList))
for i=1,#fileList do
  H.printf("      %3d: [%s]",i,fileList[i])
end

-- local structuresSourceFolder = [[D:\Robert\source\repos\MBINCompiler\libMBIN\Source\NMS\]]

-- local NMSFolders = {
  -- "GameComponents",
  -- "Globals",
  -- "Toolkit",
-- }

-- -- create fast lookup table for all structures
-- local structureList = {}
-- for i=1,#NMSFolders do
  -- local f = structuresSourceFolder..NMSFolders[i]
  -- structureList = H.ListDir(structureList,f,true,false) -- StripPath,SubDir
-- end

-- -- structureList is filled with all the structure filenames
-- print()
-- H.printf("Found %d structures",#structureList)

-- if #structureList == 0 then
  -- print("? EMPTY list of file structure, check your path")
  -- H.WFAK("in pause...")
  -- return
-- end

-- -- for i=1,10 do
  -- -- print(" - ["..structureList[i].."]")
-- -- end

-- local fastStructureLookup = {}
-- for i=1,#structureList do
  -- fastStructureLookup[string.sub(structureList[i],1,-3)..[[xml]]] = structuresSourceFolder..structureList[i]
-- end

-- local count = 0
-- for k,v in pairs(fastStructureLookup) do
  -- H.printf(" - [%70s] = [%s]",k,v)
  -- count = count + 1
  -- if count > 5 then
    -- break
  -- end
-- end

-- -- fastStructureLookup is now ready

-- H.WFAK("in pause...")

local destinationFolder = [[..\TOOLS\]]..[[TREE]]
H.mkdir(destinationFolder)

local spaceChar = " "
local tabChar = "\t"

for i=1,#fileList do
  repeat -- until we use a break to exit
    local startTimeFile = os.clock()
    
    print()
    print("  =============  =============  =============  =============  =============  =============")
    print(string.format("  Processing file %d: %s",i,tostring(fileList[i])))

    local sourceTable = H.ParseTextFileIntoTable(fileList[i])

    if #sourceTable == 0 then
      print("? EMPTY file")
      break
    end
    
    -- skip over header
    local k =0
    for j=1,#sourceTable do
      if string.find(sourceTable[j],"<Data",1,true) then
        k = j
        break
      end
    end
    
    local treeTable = {}
    local level = 0
    local lineHeader1 = "- "
    local lineHeader2 = "* "
    local indent = 2
    
    treeTable[1] = "From ==> "..fileList[i]

    for j=k,#sourceTable do
      -- if j > 20 then break end
      local lineA = sourceTable[j]
      
      if lineA == nil then
        -- bad source
        print("? Bad source file")
        treeTable = {}
        break
      end
      
      local p,v = H.GetPropertyNameValue(lineA)
      
      if j > k and string.find(sourceTable[j-1],[[">]],1,true) then
        -- treeTable[#treeTable] = "{"..string.sub(treeTable[#treeTable],2)
        level = level + 1
      end

      if string.find(lineA,"<D",1,true) then
        treeTable[#treeTable+1] = H.GetProperty(lineA)
        
      -- elseif string.find(lineA,[[</]],1,true) then
      elseif p == nil and v == nil then
        level = level - 1
        -- </Property>, skip
        
      elseif p == nil and v then
        -- found a Property value= ONLY
        treeTable[#treeTable+1] = string.rep(" ",indent*level)..lineHeader1..string.sub(v,1,-5) -- .." # List<>"
        
      elseif p and v == nil then
        -- found a Property name= ONLY
        local tmp = ""
        if string.find(lineA,[[">]],1,true) then
          if string.find(sourceTable[j+1],".xml",1,true) then
            tmp = " # List<>"
          else
            tmp = " # Array[] / ENUM"
          end
        else
          tmp = " # List<>"
        end

        treeTable[#treeTable+1] = string.rep(" ",indent*level)..lineHeader1..p..tmp
        
      else -- p and v then
        -- found Property name= AND value=
        if string.find(v,".xml",1,true) then
          -- local pn,vn = H.GetPropertyNameValue(sourceTable[j+1])

          -- local tmp = ""
          -- if vn == nil and string.find(sourceTable[j+1],".xml",1,true) then
            -- tmp = " #B: List<>"
          -- -- else
            -- -- tmp = " #B: Array[] / ENUM"
          -- end
          
          treeTable[#treeTable+1] = string.rep(" ",indent*level)..lineHeader1..p.."."..string.sub(v,1,-5) -- ..tmp
        else
          if v == "" then
            v = [[""]]
          end
          treeTable[#treeTable+1] = string.rep(" ",indent*level)..lineHeader2..p.." = "..v
        end        
      end
      
      -- H.printf("%5d,%2d: [%s] [%s]",j,level,tostring(p),tostring(v))
      
    end
    
    --treeTable[#treeTable+1] = "}"    
    
    -- = = = = = = =
    -- using DESTINATION_FOLDER
    local treeInfo = table.concat(treeTable,"\n")
    if treeInfo ~= "" then
      local filename = ""
      
      -- H.printf("    fileList[i] = [%s]",fileList[i])      

      local MainFolders = H.ParseTextFileIntoTable("NMSMainFolders.txt")
      if #MainFolders > 0 then
        -- extract relative file path
        local extraPath = ""
        for j=1,#MainFolders do
          local pos = string.find(fileList[i],[[\]]..MainFolders[j],1,true)
          if pos then
            extraPath = string.sub(fileList[i],1,pos - 1)..[[\]]
            break
          end
        end
        
        if extraPath == "" then
          -- could be a global
          filename = H.GetFilenameFromFilePath(fileList[i])
        else
          filename = string.sub(fileList[i],#extraPath + 1)
        end
      else
        -- this should not happen, handled by calling app console
        print("MISSING MainFolders List!")
      end

      -- H.printf("       filename = [%s]",filename)

      local savePath = destinationFolder..[[\]]..filename..[[.py]] -- .py for the auto-folding
      
      if H.IsFileExist(savePath) then
        H.DeleteFile(savePath)
      end
      H.mkdir(H.GetFolderPathFromFilePath(savePath))

      print()
      print(string.format("===>> Saved tree file #%d to ["..savePath.."]",i))
      
      H.WriteToFile(treeInfo,savePath)
    else
      print()
      print("? Nothing to save")
    end
    
    print()
    H.printf("      >>> file #%d done in %s",i,H.dClock(os.clock() - startTimeFile))

    break
  until true -- until we use a break to exit

end -- for i=1,#fileList do

print()
print(">>> ALL files done in "..H.dClock(os.clock() - startTimeTotal))

