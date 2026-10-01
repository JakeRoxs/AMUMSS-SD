-- [3:51 PM]Wbertro: would you also like RemoveTraillingSpaces to replace tabs with spaces AND create indent spaces of length x?
-- [4:01 PM]Babscoole: I'd be careful about that one.  No idea what a person is using for text editing and what the default tab size is in those programs.  
      -- So could drastically modify the way scripts look to them.  
      -- Just because I use NPP (4 space length tabs by default) and VSS (also 4 space length tabs by default), 
      -- shouldn't ram that down other peoples throats who use Text Editor Pro, Pilot Edit, Sublime Text, Etc, where is may be different.  ??
      -- May want to ask in the group though. 
-- [4:06 PM]Wbertro: it would not do it by default, only if 1 or 2 new switches are used:
      -- -spaceIndentSize X (where X = how many spaces to indent)
      -- -TabToSpaces           (if used would also require -spaceIndentSize x, otherwise is disabled) 
-- [4:11 PM]Wbertro: the -noindent flag still works on empty line
-- [4:12 PM]Wbertro: -spaceIndentSize works on all lines if -noindent switch is absent

local version = "1.1.0"
local DEBUG = false

dofile([[LoadHelpers.lua]])

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

-- print1("THIS file (arg[0]) = "..tostring(arg[0]).." v"..version)
print1("THIS file v"..version)
print1("Arguments passed to THIS script = "..tostring(#arg - 1))
print1()

-- for i=0,#arg do
  -- print1(i.." ["..tostring(arg[i]).."]")
-- end
-- print1()

-- process arguments
local startLine = 2

local IsNoIndent = false
local IsSpaceIndentSize = false
local SpaceIndentSize = nil
local IsTabToSpaces = false

local i = 1
while i <= #arg do
  if arg[i] == "-noindent" then
    IsNoIndent = true
    startLine = startLine + 1
    print("--> No Indent on empty lines")

  elseif arg[i] == "-spaceIndentSize" then
    i = i + 1
    IsSpaceIndentSize = true
    startLine = startLine + 1
    
    if tonumber(arg[i]) then
      SpaceIndentSize = tonumber(arg[i])
      startLine = startLine + 1
    else
      i = i - 1
      SpaceIndentSize = 4
    end
    print("--> Space Indent Size = "..SpaceIndentSize)

  elseif arg[i] == "-TabToSpaces" then
    IsTabToSpaces = true
  end

  i = i + 1
end

if IsTabToSpaces then
  if IsSpaceIndentSize then
    print("--> Convert Tabs to Spaces")
    startLine = startLine + 1
  else
    IsTabToSpaces = false
  end
end
-- END: process arguments

if startLine > 2 then
  print()
end

local fileList = {}
if arg[2] == nil then
  print("? No file to process")
  return
else
  -- print1("arg startLine = "..startLine)
  for i=startLine,#arg do
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

if IsNoIndent then
  print("  ============= REMOVING trailing spaces =============")
else
  print("  ============= REMOVING trailing spaces on non-empty lines =============")
end

print("Files to process = "..tostring(#fileList))
for i=1,#fileList do
  print("      ["..fileList[i].."]")
end

local destinationFolder = [[..\TOOLS\]]..[[CLEANED]]
H.mkdir(destinationFolder)

local spaceChar = " "
local tabChar = "\t"

for i=1,#fileList do
  repeat -- until we use a break to exit
    local startTimeFile = os.clock()
    
    print()
    print("  =============  =============  =============  =============  =============  =============")
    print(string.format("  Processing file %s: %s",string.char(i + 64),tostring(fileList[i])))

    local sourceTable = H.ParseTextFileIntoTable(fileList[i])

    if #sourceTable == 0 then
      print("? EMPTY file")
      break
    end
    
    H.printf("  #fileLines = %d",#sourceTable)

    -- check if all line only use leading tabs or leading spaces
    local onlyLeadingTabs = false
    local onlyLeadingSpaces = false
    local mixedIndent = false
    local linesWithTabs = 0
    local linesWithSpaces = 0
    local linesWithBoth = 0
    
    local leadingSpaceLength = {}
    for j=1,#sourceTable do
      local lineA = H.rtrim(sourceTable[j])
      if lineA ~= "" then
        local leadingString = string.match(lineA,"(%s+)")
        if leadingString then
          -- print1(string.format("%2d: leadingString = [%s], count = %d",j,leadingString,#leadingString))
          local _,tabCount = string.gsub(leadingString,"\t","\t",-1)
          local _,spaceCount = string.gsub(leadingString," "," ",-1)
          
          local whiteSpaceCount = #leadingString
          leadingSpaceLength[whiteSpaceCount] = (leadingSpaceLength[whiteSpaceCount] or 0) + 1
          
          if spaceCount > 0 then
            linesWithSpaces = linesWithSpaces + 1
          end
          if tabCount > 0 then
            linesWithTabs = linesWithTabs + 1
          end
          if spaceCount > 0 and tabCount > 0 then
            linesWithBoth = linesWithBoth + 1          
          end
        else
          -- print1(string.format("%2d: leadingString = [%s], count = %d",j,"",0))
          leadingSpaceLength[0] = (leadingSpaceLength[0] or 0) + 1
        end
      else
        -- print1(string.format("%2d: leadingString = [%s], count = %d",j,"",0))
        leadingSpaceLength[0] = (leadingSpaceLength[0] or 0) + 1
      end
    end
    
    if linesWithTabs > 0 and linesWithSpaces > 0 then
      mixedIndent = true
    end

    H.printf("  linesWithTabs = %d",linesWithTabs)
    H.printf("linesWithSpaces = %d",linesWithSpaces)
    H.printf("  linesWithBoth = %d",linesWithBoth)
    
    print()
    if mixedIndent then
      print("@@@ [WARNING] Mixed 'tab' and 'space' indentation type: Indentation result may be sub-optimal!")
      print("              Better check the CLEANED file.")
      print("              --> BETTER use a text editor to convert TAB to SPACE")
      H.WFAK("press a key to continue...")
    elseif linesWithTabs > 0 then
      print("@@@ This file only uses 'tab' indentation")
      onlyLeadingTabs = true
    elseif linesWithSpaces > 0 then
      print("@@@ This file only uses 'space' indentation")
      onlyLeadingSpaces = true
    end
    
    print()
    H.printf("Space Lengths = quantity: count = %d",#leadingSpaceLength + 1)
    for j=0,#leadingSpaceLength do
      H.printf("%2d = %s",j,tostring(leadingSpaceLength[j]))
    end
    print()
    
    -- -- find a line with only one leading tab and a line with only spaces
    -- for j=1,#sourceTable do
      -- local lineA = H.rtrim(sourceTable[j])
      
      -- if lineA ~= "" then
        -- local leadingString = string.match(lineA,"(%s+)")
        -- if leadingString then
          -- local spaceNum = #lineA - #H.ltrim(lineA)
          -- print1(string.format("%2d: spaceNum = %d, [%s]",j,spaceNum,lineA))

          -- print1(string.format("%2d: leadingString = [%s] %d long",j,leadingString,#leadingString))
          
          -- local _,tabCount = string.gsub(leadingString,"\t","\t",-1)
          -- print1(string.format("    tabCount = %d",tabCount))

          -- local _,spaceCount = string.gsub(leadingString," "," ",-1)
          -- print1(string.format("  spaceCount = %d",spaceCount))
          
          -- if tabCount == 1 and spaceCount == 0 then
          -- end
          
        -- else
          -- print1(string.format("%2d: leadingString = [%s]",j,leadingString))
        -- end
      -- end
    -- end
    
    for j=1,#sourceTable do
      local lineA = H.rtrim(sourceTable[j])
      
      if lineA ~= "" then
        if IsSpaceIndentSize then
          if IsTabToSpaces then
            -- remove leading tabs and spaces
            local leadingString = string.match(lineA,"(%s+)")
            
            local spaceNum = #lineA - #H.ltrim(lineA)
            -- print1(string.format("%2d: spaceNum = %d, [%s]",j,spaceNum,lineA))
          
          else
            -- change spaces/tabs to new indent size
          end
          
        else
          -- no change in indent size nor tabs
          sourceTable[j] = lineA
        end
        
      elseif j > 1 then
        -- this is an empty line
        
        lineC = ""
        if not IsNoIndent then
          --    let us copy the left spacing of the previous line
          local lineB = sourceTable[j - 1]
          local spaceNum = #lineB - #H.ltrim(lineB)
          
          if spaceNum > 0 then
            -- are these spaces or tab?
            -- we need to preserve the tabs and spaces
            lineC = string.sub(lineB,1,spaceNum)
          end
        end
        sourceTable[j] = lineC..H.ltrim(lineA)
      end
    end
    
    -- = = = = = = =
    -- using DESTINATION_FOLDER
    local moddedContent = table.concat(sourceTable,"\n")
    if moddedContent ~= "" then
      local savePath = destinationFolder..[[\]]..H.GetFilenameFromFilePath(fileList[i])
      
      if H.IsFileExist(savePath) then
        H.DeleteFile(savePath)
      end
      H.mkdir(H.GetFolderPathFromFilePath(savePath))

      print()
      print(string.format("===>> Saved file #%d to ["..savePath.."]",i))
      
      H.WriteToFile(moddedContent,savePath)
    else
      print()
      print("? Nothing to save")
    end
  
    print()
    H.printf("      >>> file #%d done in %s",i,H.dClock(os.clock() - startTimeFile))
    
  until true -- until we use a break to exit

end -- for i=1,#fileList do

print()
print(">>> ALL files done in "..H.dClock(os.clock() - startTimeTotal))

