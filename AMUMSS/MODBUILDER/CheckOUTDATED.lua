-- ****************************************************
-- main
-- ****************************************************

--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER
--arg[3] == a message --not used
--arg[4] == "DoSuspicious" if turned ON
--arg[5] == 1 NOT USED

if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
-- print(">>>     In CheckOUTDATED.lua")
H.gfilePATH = arg[1] --used by LoadHelpers.Report()
THIS = "In CheckOUTDATED: "

local string = string
  local strsub = string.sub
  local strgsub = string.gsub
  local strfind = string.find
  local strlen = string.len -- much better to use #, if you can
  local strupper = string.upper
  local strrep = string.rep
  local strformat = string.format
local print = print
local tostring = tostring
local tonumber = tonumber
local type = type
local table = table
local math = math
local os = os

local LDebug = LDebug

local IsDoSuspicious = (arg[4] == "DoSuspicious")
local maxPakNameLength = 25

-- local maxNMSpathLength = 0
-- local NMSpaths = H.ParseTextFileIntoTable([[..\TOOLS\NMS_FULL_pak_list.txt]])
-- local longuestNMSPath = ""
-- for i=1,#NMSpaths do
  -- if #NMSpaths[i] > maxNMSpathLength then
    -- maxNMSpathLength = #NMSpaths[i]
    -- longuestNMSPath = NMSpaths[i]
  -- end
-- end
-- H.printf("==> Longuest NMS path found: %d, [%s]",maxNMSpathLength,longuestNMSPath)

local countPaks = 0
local countNotUnpacked = 0

-- ********************************************************************************
local function checkOUTDATED(folderPath,outdatedTable,folderToInspect)
  -- local outdatedTable = H.ParseTextFileIntoTable([[MODS_pak_list.txt]])

  -- Example:
    -- FROM MODS 
    -- Listing AtmoHover-PulseSpeedDefined.pak
    -- AMUMSS.v4.5.7.1W.txt (0/0 100%)
    -- AtmoHover-PulseSpeedDefined.lua (1016/3681 27%)
    -- GCSPACESHIPGLOBALS.GLOBAL.MBIN (1955/6658 29%)
     
    -- Listing QS Daily Mission Reward 2x.pak
    -- AMUMSS.v4.5.7.1W.txt (0/0 100%)
    -- METADATA/REALITY/TABLES/REWARDTABLE.MBIN (91617/892440 10%)
    -- QS Daily Mission Reward AIO.lua (842/2055 40%)
     
    -- Listing QS Missions and Daily Reward Multiplier 2x.pak
    -- AMUMSS.v4.5.7.1W.txt (0/0 100%)
    -- METADATA/REALITY/TABLES/REWARDTABLE.MBIN (91683/892824 10%)
    -- QS Missions and Daily Reward Multiplier AIO.lua (1235/3723 33%)
     
    -- Listing _Waterworld Booster.pak
    -- AMUMSS.v4.5.7.1W.txt (0/0 100%)
    -- METADATA/SIMULATION/SOLARSYSTEM/BIOMES/BIOMELISTPERSTARTYPE.MBIN (148/964 15%)
    -- _Waterworld Booster.lua (309/830 37%)
     
    -- Listing _Weird Booster.pak
    -- AMUMSS.v4.5.7.1W.txt (0/0 100%)
    -- METADATA/SIMULATION/SOLARSYSTEM/BIOMES/BIOMELISTPERSTARTYPE.MBIN (135/964 14%)
    -- _Weird Booster.lua (333/1057 31%)

  local CSTable = {}
  for i=1,#outdatedTable do
    local text = outdatedTable[i]
    if text and H.trim(text) ~= "" then
      CSTable[#CSTable+1] = strgsub(text,[[/]],[[\]])
    end
  end

  -- print("=== CSTable dump ===")
  -- for i=1,#CSTable do
    -- print(" # "..CSTable[i].."")
  -- end
  -- print("=== END: CSTable dump ===")

  local GUIDtableExist = false
  local GUIDtable = {}
  if #CSTable > 0 then
    -- load GUID of NMS files
    
    -- WE NEED TO CHECK IF GUID_MBIN_DATA.lua is UPDATED
    --   if Date Modified is more recent than GAMEDATA\PCBANKS\BankSignatures.bin
    local GUID_MBIN_Data_Modified = lfs.attributes(arg[2].."GUID_MBIN_DATA.lua","modification")
    -- GUID_MBIN_Data_Modified = 0 -- for testing
    local BankSignatures_Modified = lfs.attributes(H.gNMS_PCBANKS_FOLDER_PATH..[[BankSignatures.bin]],"modification")
    -- H.printf("GUID_MBIN_Data_Modified = %s",GUID_MBIN_Data_Modified)
    -- H.printf("BankSignatures_Modified = %s",BankSignatures_Modified)
    
    if GUID_MBIN_Data_Modified >= BankSignatures_Modified then
      -- create fast table on filename
      local GUID_MBIN_Data = H.ParseTextFileIntoTable("GUID_MBIN_Data.lua")
      for i=1,#GUID_MBIN_Data do
        GUIDtable[string.sub(GUID_MBIN_Data[i],33)] = string.sub(GUID_MBIN_Data[i],15,30)
      end
      GUIDtableExist = true
    end
  end

  -- For DEBUG
  -- GUIDtableExist = false

  if GUIDtableExist then
    print(">>> "..H._zBRIGHTGREEN.."   Done retrieving NMS files GUID"..H._zDEFAULT)
  end
  
  -- local countPaks = 0
  local orgPakName = ""
  local pakName = ""
  local fileCount = 0

  local entries = {}
  for i=1,#CSTable do
    local text = CSTable[i]
    
    if strfind(text,"Listing",1,true) then
      fileCount = 0 -- reset
      orgPakName = strsub(text,strfind(text," ",1,true)+1)
      H.Report(""," - "..orgPakName)
      
                           -- MBINname, pakName, NMSpakName, GUID_NMSfile,     GUID_MBINpak,      orgPakNAme, folderToInspect
      entries[#entries + 1] = { "NONE", pakName , "NONE", "0000000000000000", "0000000000000000", orgPakName, folderToInspect }
      
      -- H.printf("@@@ orgPakName = [%s]",orgPakName)
      if #orgPakName > maxPakNameLength then
        local n = 0
        repeat
          local found = false
          n = n + 1
          pakName = strsub(orgPakName,1,maxPakNameLength).." ("..n..")"
          for j=1,#entries do
            if entries[j][2] == pakName then
              found = true
              break
            end
          end
        until not found and not H.IsDirExist([[.\_O\]]..pakName)
      else
        pakName = orgPakName
      end
      -- H.printf("   @@@ pakName = [%s]",pakName)
      entries[#entries][2] = pakName
      
      countPaks = countPaks + 1
      
    elseif strfind(text,".MBIN",1,true) then
      -- file is in which NMSpak?
      -- H.printf("text = [%s]",text)
      -- local file = strsub(text,1,strfind(text," ",1,true)-1)
      local file = text
      if strsub(file,1,1) == [[\]] or strsub(file,1,1) == [[/]] then
        file = strsub(file,2)
      end
      
      local NMSpakName = H.gFastPAKlist[file]
      if NMSpakName == nil then
        NMSpakName = "UNKNOWN" -- NOT in any NMS pak
      end
      
      local GUID_NMSfile = GUIDtable[file]
      if GUID_NMSfile == nil then
        GUID_NMSfile = "0000000000000000"
      end
      
      local GUID_MBINpak = "0000000000000000"
      fileCount = fileCount + 1
      entries[#entries + 1] = { file, pakName, NMSpakName, GUID_NMSfile, GUID_MBINpak, orgPakName, folderToInspect }
    end
  end
  H.Report("")

  -- print("")
  -- for i=1,#entries do
    -- H.printf(" + [%75s] [0x%16s] [%25s] [0x%16s] [%s]",entries[i][1],entries[i][5],entries[i][3],entries[i][4],entries[i][2])
  -- end
  
  -- + [                                             GCSPACESHIPGLOBALS.GLOBAL.MBIN] [0x0000000000000000] [       NMSARC.globals.pak] [0x761975B03BE884C4] [AtmoHover-PulseSpeedDefined.pak]
  -- H.WFAK()

  -- retrieve GUID from files in paks
  
  -- 1st: need to extract MBIN files
  if #entries > 0 then
    print("")
    print(">>> "..H._zBRIGHTGREEN.."Extracting..."..H._zDEFAULT)

    if not GUIDtableExist then
      -- we need to get NMS GUID ourselves
      print(">>> "..H._zBRIGHTGREEN.."Getting GUID from NMS files..."..H._zDEFAULT)
      local input = {}
      input[#input+1] = "<psarc>"
      
      for i=1,#entries do
        if entries[i][3] ~= "UNKNOWN" then
          input[#input+1] = [[    <extract archive="]]..H.gNMS_PCBANKS_FOLDER_PATH..entries[i][3]..[[" to=".\_O\NMS]]..[[" stripall="false" skipmissingfiles="true" overwrite="true">]]
          input[#input+1] = [[        <file archivepath="]]..entries[i][1]..[[" skipifmissing="true" />]]
          input[#input+1] = "    </extract>"
        end
      end
      
      input[#input+1] = "</psarc>"
      
      H.WriteToFile(H.ConvertLineTableToText(input),[[ExtractFromNMSPaks.xml]])
      
      -- use input file to try extracting from paks
      local cmd = [[cmd /c psarc.exe --xml=ExtractFromNMSPaks.xml >Extract_NMSPaksResult.txt]]
      local state,sResult,nResult = os.execute(cmd)
            
      -- get GUID of the files in .\_O\NMS
      for i=1,#entries do
        -- H.printf("Processing [%s]",[[.\_O\NMS\]]..entries[i][1])
        if entries[i][3] ~= "UNKNOWN" then
          local fileHandle = io.open([[.\_O\NMS\]]..entries[i][1],"rb")
          if fileHandle then
            -- get GUID
            fileHandle:seek("set",0x10) --goto start of GUID
            local data = fileHandle:read(10)
            fileHandle:close()
            -- H.printf("data = [%s]",tostring(data))
            -- data = string.sub(data,1,10)
            -- H.printf("data = [%s]",tostring(data))
            if data and #data == 10 then
              local GUID = ""
              local j = 1
              while true do
                local d
                d,j = string.unpack("<I2",data,j)
                -- print(d,i)
                if j > #data then break end
                local ds = string.format("%0X",d)
                while #ds < 4 do
                  ds = "0"..ds
                end          
                GUID = ds..GUID
              end
              -- print("   GUID = ["..[[0x]]..GUID.."]")
              --ex.: "72E67855FFA1A753" GcCharacterGlobals
              entries[i][4] = GUID
            else
              H.Report("","Cannot get GUID from "..[[.\_O\NMS\]]..entries[i][1],"WARNING")
            end
          -- else
            -- this can happen when the file os NOT an NMS file, but a script created file
          end
        end
      end
      print(">>> "..H._zBRIGHTGREEN.."   Done extracting NMS files GUID"..H._zDEFAULT)
    end

    -- let us try one pak at the time
    print(">>> "..H._zBRIGHTGREEN.."Extracting pak files..."..H._zDEFAULT)
    H.Report("",">>> Extracted pak files:")
    
    local totalPakCount = 0
    local pakName = ""
    local j = 1
    while j <= #entries do
      if pakName ~= entries[j][2] then
        pakName = entries[j][2]
        totalPakCount = totalPakCount + 1
      end
      
      local MBINfileCount = 0
      local input = {}
      input[#input+1] = "<psarc>"
      input[#input+1] = [[    <extract archive="]]..folderPath..[[\]]..entries[j][6]..[[" to=".\_O\]]..pakName..[[" stripall="false" skipmissingfiles="true" overwrite="true">]]
      
      while j <= #entries do
        if entries[j][2] == pakName then
          if entries[j][3] ~= "UNKNOWN" and entries[j][1] ~= "NONE" then
            input[#input+1] = [[        <file archivepath="]]..entries[j][1]..[[" skipifmissing="true" />]]
            MBINfileCount = MBINfileCount + 1
          end
          j = j + 1
        else
          break
        end
      end
      
      input[#input+1] = "    </extract>"
      input[#input+1] = "</psarc>"
      
      H.WriteToFile(H.ConvertLineTableToText(input),[[ExtractFromMODSPaks.xml]])
      
      if MBINfileCount > 0 or entries[j-1][1] == "NONE" then
        H.printf(" - "..H._zYELLOW.."%s"..H._zDEFAULT.." (%d MBINs)",entries[j-1][6],MBINfileCount)
        H.Report("",[[ - "]]..entries[j-1][6]..[[" (]]..MBINfileCount.." MBINs)")
      end
            
      -- use input file to try extracting from paks
      local cmd = [[cmd /c psarc.exe --xml=ExtractFromMODSPaks.xml >Extract_MODSPaksResult.txt]]
      local state,sResult,nResult = os.execute(cmd)
    end -- while j <= #entries do
    
    H.printf(">>> "..H._zBRIGHTGREEN.."   Done extracting %d 'normal' pak files"..H._zDEFAULT,totalPakCount)
    
    -- H.WFAK()
    
    --  entries[#entries + 1] = { file, pakName, NMSpakName, GUID_NMSfile, GUID_MBINpak, orgPakName, folderToInspect }
    
    local stillToUnpack = {}
    for i=1,#entries do
      if entries[i][1] ~= "NONE" then
        if not H.IsFileExist([[.\_O\]]..entries[i][2]..[[\]]..entries[i][1]) then
          -- WBERTRO        -- maybe list the files to know what to use before psarc extract?
          -- H.printf(" + custom: [%s]",entries[i][2]..[[\]]..entries[i][1])
          stillToUnpack[#stillToUnpack+1] = entries[i]
        end
      end
    end
    
    if #stillToUnpack > 0 then
      print(">>> "..H._zBRIGHTGREEN.."Extracting 'custom' pak files (if any)..."..H._zDEFAULT)
      H.Report("",">>>    Extracted 'custom' pak files (if any):")
    end
    
    local totalPakCount = 0
    local totalCustomFiles = 0
    local pakName = ""
    local i = 1
    while i <= #stillToUnpack do
      -- trying alternate method
      if pakName ~= stillToUnpack[i][2] then
        pakName = stillToUnpack[i][2]
        -- H.printf(" - [%s]",pakName)
        totalPakCount = totalPakCount + 1
      end
      --                              1       2         3           4             5             6             7
      --  entries[#entries + 1] = { file, pakName, NMSpakName, GUID_NMSfile, GUID_MBINpak, orgPakName, folderToInspect }
      
      local MBINfileCount = 0
      local input = {}
      input[#input+1] = "<psarc>"
      input[#input+1] = [[    <extract archive="]]..folderPath..[[\]]..stillToUnpack[i][6]..[[" to=".\_O\]]..pakName..[[" stripall="false" skipmissingfiles="true" overwrite="true">]]
      -- input[#input+1] = [[    <extract archive="]]..stillToUnpack[i][6]..[[" to=".\_O\]]..pakName..[[" stripall="false" skipmissingfiles="true" overwrite="true">]]
      
      while i <= #stillToUnpack do
        if stillToUnpack[i][2] == pakName then
          -- H.printf(" ~ [%75s] [0x%16s] [%25s] [0x%16s] [%s]",stillToUnpack[i][1],stillToUnpack[i][5],stillToUnpack[i][3],stillToUnpack[i][4],stillToUnpack[i][2])
          if stillToUnpack[i][3] ~= "UNKNOWN" then
            input[#input+1] = [[        <file archivepath="/]]..stillToUnpack[i][1]..[[" skipifmissing="true" />]] -- / required for some custom paks
            MBINfileCount = MBINfileCount + 1
          end
          i = i + 1
        else
          break
        end
      end -- while i <= #stillToUnpack do

      if MBINfileCount > 0 then
        totalCustomFiles = totalCustomFiles + MBINfileCount
        
        input[#input+1] = "    </extract>"
        input[#input+1] = "</psarc>"
        
        H.WriteToFile(H.ConvertLineTableToText(input),[[ExtractFromMODSPaksAlt.xml]])
        
        -- H.printf("MBINfileCount = %d",MBINfileCount)
        -- H.WFAK("AFTER writing to ExtractFromMODSPaksAlt.xml")
      
        H.printf(" - "..H._zYELLOW.."%s"..H._zDEFAULT.." (%d MBINs)",stillToUnpack[i-1][6],MBINfileCount)
        H.Report("",[[ - "]]..stillToUnpack[i-1][6]..[[" (]]..MBINfileCount.." MBINs)")
      
        -- use input file to try extracting from paks
        local cmd = [[cmd /c psarc.exe --xml=ExtractFromMODSPaksAlt.xml >Extract_MODSPaksResultAlt.txt]]
        local state,sResult,nResult = os.execute(cmd)
        
        -- print(" -    @@@ EXTRACT_B: result = ["..string.format("%s, %s (%d)",state,sResult,nResult).."] for ["..stillToUnpack[i][6].."]")
        if state == nil then
          countNotUnpacked = countNotUnpacked + 1
          -- H.printf("     ==> psarc reported some files could not be unpacked in [%s]",stillToUnpack[i][6])
          print("     ==> psarc reported some files could not be unpacked")
          H.Report("","     ==> psarc reported some files could not be unpacked")
          
          H.printf("folderPath = [%s]",folderPath)
          H.printf("stillToUnpack[%d][6] = [%s]",i-1,stillToUnpack[i-1][6])
          local success,result = H.psarc_CL("LIST", folderPath, stillToUnpack[i-1][6], true, false)
          -- H.printf("result = [%s]",result)
          local listTableIndexed = {}
          -- for k,v in string.gmatch(result, "(.-) %b()%c") do
          for k,v in string.gmatch(result, "%c(.-) %b()") do
            listTableIndexed[#listTableIndexed + 1] = k
          end        
          -- H.printf("==> #listTableIndexed = %d",#listTableIndexed)
          -- local count = 0
          -- for k,v in ipairs(listTableIndexed) do
            -- H.printf(" = [%s]",v)
            -- count = count + 1
            -- if count > 10 then
              -- break
            -- end
          -- end
          
          for j=1,#listTableIndexed do
            if string.find(listTableIndexed[j],[[.MBIN]],1,true) and not H.IsFileExist([[.\_O\]]..pakName..[[\]]..listTableIndexed[j]) then
              H.printf("     - could not unpack "..H._zBRIGHTORANGE.."%s in %s"..H._zDEFAULT,listTableIndexed[j],stillToUnpack[j][6])
              H.Report("","      - could not unpack "..listTableIndexed[j].." in "..stillToUnpack[j][6])
            end
          end
        end -- if state == nil then
      end -- if MBINfileCount > 0 then
    end -- while i <= #stillToUnpack do

    if #stillToUnpack > 0 then
      if totalCustomFiles == 0 then
        print("       No custom file to extract")
        H.Report("","    No custom file to extract")
      else
        H.printf(">>> "..H._zBRIGHTGREEN.."   Done extracting %d 'custom' pak files"..H._zDEFAULT,totalPakCount)
      end
    end

    -- get GUID of the files in MODS
    for i=1,#entries do
      if entries[i][4] ~= "0000000000000000" then -- skip files without NMS GUID
        local fileHandle = io.open([[.\_O\]]..entries[i][2]..[[\]]..entries[i][1],"rb")
        if fileHandle then
          -- get GUID
          local pos = fileHandle:seek("set",0x10) --goto start of GUID
          local data = fileHandle:read(10)
          fileHandle:close()
          if data and #data == 10 then
            local GUID = ""
            local j = 1
            while true do
              local d
              d,j = string.unpack("<I2",data,j)
              -- print(d,j)
              if j > #data then break end
              local ds = string.format("%0X",d)
              while #ds < 4 do
                ds = "0"..ds
              end          
              GUID = ds..GUID
            end
            -- print("   GUID = ["..[[0x]]..GUID.."]")
            --ex.: "72E67855FFA1A753" GcCharacterGlobals
            entries[i][5] = GUID
          else
            print("Cannot get GUID from [".._zBRIGHTORANGE..entries[i][6]..[[\]]..entries[i][1]..H._zDEFAULT.."]")
            H.Report("","Cannot get GUID from ["..entries[i][6]..[[\]]..entries[i][1].."]")
            -- H.printf("   data = [%s]",tostring(data))
          end
        -- else
          -- print([[WARNING: Could not open .\_O\]]..entries[i][2]..[[\]]..entries[i][1])
        end
      end
    end
  end
  
  return entries
end
-- ********************************************************************************

print()
print(">>> "..H._zBRIGHTGREEN.."Checking OUTDATED. Please wait..."..H._zDEFAULT)

-- print("          lfs = "..lfs.currentdir())
-- print("AAAAAA arg[1] = ["..tostring(arg[1]).."]")
-- print("AAAAAA arg[2] = ["..tostring(arg[2]).."]")
-- print("AAAAAA arg[3] = ["..tostring(arg[3]).."]")
-- print("AAAAAA arg[4] = ["..tostring(arg[4]).."]")
-- print("AAAAAA arg[5] = ["..tostring(arg[5]).."]")

local sTime = os.clock()

-- local NMS_FOLDER = H.LoadFileData([[..\CONFIG\NMS_FOLDER.txt]])
-- NMS_FOLDER = string.gsub(NMS_FOLDER,"\n","") --remove line break if any

-- H.gNMS_GAMEDATA_FOLDER_PATH = NMS_FOLDER..[[\GAMEDATA\]]
-- H.gNMS_PCBANKS_FOLDER_PATH = H.gNMS_GAMEDATA_FOLDER_PATH..[[PCBANKS\]]
-- H.gNMS_MODS_FOLDER = H.gNMS_GAMEDATA_FOLDER_PATH..[[MODS]]

H.DeleteDir([[.\_O]])
H.mkdir([[.\_O]])

local foldersToInspectTable = {}
local IsMods = true
if H.IsFileExist[[..\CONFIG\OUTDATED_CheckList.txt]] then
  -- print("OUTDATED_CheckList.txt exist")
  foldersToInspectTable = H.ParseTextFileIntoTable([[..\CONFIG\OUTDATED_CheckList.txt]])
  for i=1,#foldersToInspectTable do
    if H.trim(foldersToInspectTable[i]:upper()) == "NOMODS" then
      IsMods = false
      break
    end
  end
end

if IsMods then
  table.insert(foldersToInspectTable,1,H.gNMS_MODS_FOLDER)
end

local outdatedEntries = {}
for i=1,#foldersToInspectTable do
  local pakListTable = {}
  if foldersToInspectTable[i] ~= "" then    
    if H.IsDirExist(foldersToInspectTable[i]) then
      print("")
      H.printf(" ==> Processing folder:"..H._zBRIGHTORANGE.." %s "..H._zDEFAULT,foldersToInspectTable[i])
      -- print(H._zBRIGHTGREEN.."List of PAK file(s):"..H._zDEFAULT)
      H.Report("")
      H.Report("",[[ ==> Processing folder: "]]..foldersToInspectTable[i]..[["]])
      H.Report("","List of PAK file(s):")
      
      -- create pak_list.txt
      local folder = foldersToInspectTable[i]
      if strsub(folder,1,1) == [[\]] or strsub(folder,1,1) == [[/]] then
        folder = strsub(folder,2)
      end
      pakListTable[#pakListTable+1] = "FROM "..folder
      
      -- ********************************************************************************
      local function getPakList(list,path,IsSubDir) -- recursive
        for file in lfs.dir(path) do
          if file ~= "." and file ~= ".." then
            local f = path..[[\]]..file
            local attr,msg = lfs.attributes(f)
            
            if attr then      
              -- assert(type(attr) == "table")

              if attr.mode == "file" then
                list[#list+1] = file
              end
              
              if IsSubDir and attr.mode == "directory" then
                list = getPakList(List,f,IsSubDir) -- recursive
              end
            end
          end
        end
        return list
      end
      -- ********************************************************************************
      
      local listTable = {}
      listTable = getPakList(listTable,folder,false)
      -- pakListTable = H.tableUnion(false,pakListTable,listTable)
      
      -- print("")
      -- this is the list of paks in the folder (no sub-folders)
      H.printf(">>> "..H._zBRIGHTGREEN.."Found %d paks to inspect in this folder"..H._zDEFAULT,#listTable)
      for j=1,#listTable do
        local s = string.upper(listTable[j])
        if string.find(s,"%.PAK$") or string.find(s,".PAK.",1,true) then
          H.printf(" * %s",listTable[j])
        end
      end
      print("")
      
      -- H.printf(" ?0 folder = [%s]",folder)
      -- H.printf(" ?1 folder = [%s]",H.escapeMagicString(folder))
      local escapeFolderString = H.escapeMagicString(folder)
      for j=1,#listTable do
        local s = string.upper(listTable[j])
        if string.find(s,"%.PAK$") or string.find(s,".PAK.",1,true) then
          -- H.printf("===         escapeFolderString = [%s]",escapeFolderString)
          -- H.printf("=== listTable[j] = [%s]",s)
          -- CONVERTED TO HGPAKTool.exe
          local success,result = H.psarc_CL("LIST", folder, listTable[j], true, false)
          -- H.printf("result = [%s]",result)
          -- for k,v in string.gmatch(result, "(.-) %b()%c") do
          -- H.printf(" ? [%s]",string.match(result, "(.-)%c"))
          pakListTable[#pakListTable+1] = string.gsub(string.match(result, "(.-)%c"),escapeFolderString..[[\]],"")
          for k,v in string.gmatch(result, "%c(.-) %b()") do
            pakListTable[#pakListTable+1] = k
          end
        end
      end
      
      -- for DEBUG
      -- print("")
      -- for j=1,#pakListTable do
        -- if string.find(pakListTable[j],"Listing",1,true) then
          -- print("")
          -- local folder = pakListTable[j]
          -- if strsub(folder,1,1) == [[\]] or strsub(folder,1,1) == [[/]] then
            -- folder = strsub(folder,2)
          -- end
          -- H.printf(" %s",folder)
        -- else
          -- H.printf(" %s",pakListTable[j])
        -- end
      -- end
      
      -- check OUTDATED in this pakListTable
      local entries = checkOUTDATED(folder,pakListTable,foldersToInspectTable[i])
      outdatedEntries = H.tableUnion(false,outdatedEntries,entries)
    end
  end
end

-- H.WFAK()

-- print("")
-- for i=1,#outdatedEntries do
  -- if outdatedEntries[i][5] ~= "0000000000000000" or outdatedEntries[i][4] ~= "0000000000000000" then
    -- H.printf(" + [%99s] [0x%16s] [%25s] [0x%16s] [%s]",outdatedEntries[i][1],outdatedEntries[i][5],outdatedEntries[i][3],outdatedEntries[i][4],outdatedEntries[i][2])
  -- end
-- end

  -- + [                                             GCSPACESHIPGLOBALS.GLOBAL.MBIN] [0x761975B03BE884C4] [       NMSARC.globals.pak] [0x761975B03BE884C4] [AtmoHover-PulseSpeedDefined.pak]
  -- + [                                   METADATA\REALITY\TABLES\REWARDTABLE.MBIN] [0x1B4831C5B109ED04] [      NMSARC.Precache.pak] [0x1B4831C5B109ED04] [QS Daily Mission Reward 2x.pak]
  -- + [                                   METADATA\REALITY\TABLES\REWARDTABLE.MBIN] [0x1B4831C5B109ED04] [      NMSARC.Precache.pak] [0x1B4831C5B109ED04] [QS Missions and Daily Reward Multiplier 2x.pak]
  -- + [           METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BIOMELISTPERSTARTYPE.MBIN] [0x373F7C6FBE5C8178] [      NMSARC.Precache.pak] [0x373F7C6FBE5C8178] [_Waterworld Booster.pak]
  -- + [           METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BIOMELISTPERSTARTYPE.MBIN] [0x373F7C6FBE5C8178] [      NMSARC.Precache.pak] [0x373F7C6FBE5C8178] [_Weird Booster.pak]

local count = 0
local countOutdated = 0
local countSuspicious = 0

local suspiciousTable = {}
local outdatedTable = {}

local pakName = ""
for i=1,#outdatedEntries do
  if pakName ~= outdatedEntries[i][6] then
    pakName = outdatedEntries[i][6]
  end

  if outdatedEntries[i][3] == "UNKNOWN" then
    suspiciousTable[#suspiciousTable+1] = { pakName, outdatedEntries[i][1] }
    count = count + 1
    countSuspicious = countSuspicious + 1
    
  else
    if outdatedEntries[i][5] ~= outdatedEntries[i][4] then
      outdatedTable[#outdatedTable+1] = { pakName, outdatedEntries[i][1], outdatedEntries[i][5], outdatedEntries[i][4], outdatedEntries[i][7] }
      -- H.printf(" + [%99s] [0x%16s] [0x%16s] [%s] [%s]",outdatedTable[#outdatedTable][1], outdatedTable[#outdatedTable][3], outdatedTable[#outdatedTable][4], outdatedTable[#outdatedTable][2], outdatedTable[#outdatedTable][7])
      count = count + 1
      countOutdated = countOutdated + 1
    end
    
  end
end

-- H.printf("outdatedTable = %d",#outdatedTable)

print("")
print("           ===== "..H._zBRIGHTORANGE.."RESULTS"..H._zDEFAULT.." =====")
print("=== "..H._zBRIGHTGREEN.."OUTDATED files in paks (GUID pak vs current):"..H._zDEFAULT)
H.Report("")
H.Report("","           ===== 'RESULTS' =====")
H.Report("","=== OUTDATED files in paks (GUID pak vs current): {")

-- print/Report list of OUTDATED
local printLimit = 10
local printCount = 0
local IsTooMany = false

local pakName = ""
local folderToInspect = ""
-- local notDone = true
for i=1,#outdatedTable do
  if pakName ~= outdatedTable[i][1] or folderToInspect ~= outdatedTable[i][5] then
    if i > 1 then
      -- H.Report("","     - "..outdatedTable[i-1][1].."(0x"..outdatedTable[i-1][3].." # 0x"..outdatedTable[i-1][4]..") }")
      H.Report("","     - "..outdatedTable[i-1][2].." }")
    end
    pakName = outdatedTable[i][1]

    if folderToInspect ~= outdatedTable[i][5] then
      folderToInspect = outdatedTable[i][5]
      H.printf(">>> From "..H._zBRIGHTORANGE.." %s "..H._zDEFAULT,folderToInspect)
      H.Report("",[[{>>> From "]]..folderToInspect..[["]])
    end
    
    H.printf("  >> "..H._zWHITEonDARKCYAN.." %s "..H._zDEFAULT,pakName)
    H.Report("",[[{ >> "]]..pakName..[["]])

    printCount = 0 -- reset
    IsTooMany = false -- reset
  else
    -- H.Report("","     - "..outdatedTable[i][1].."(0x"..outdatedTable[i][3].." # 0x"..outdatedTable[i][4]..")")
    H.Report("","     - "..outdatedTable[i-1][2])
  end

  printCount = printCount + 1
  if printCount <= printLimit then
    -- H.printf("        - %s (0x%s # 0x%s)",pakName,outdatedTable[i][3],outdatedTable[i][4])
    H.printf("        - %s",outdatedTable[i][2])
  elseif not IsTooMany then
    print("   ... Too many, see REPORT.lua")
    IsTooMany = true
  end
end

if #outdatedTable > 0 and outdatedTable[#outdatedTable][2] and outdatedTable[#outdatedTable][2] ~= "" then
  -- handle the last one
  H.Report("","     - "..outdatedTable[#outdatedTable][2].." }")
end
  
if IsDoSuspicious then
  print("")
  print("=== "..H._zBRIGHTGREEN.."SUSPICIOUS files in paks (GUID pak vs current):"..H._zDEFAULT)
  H.Report("}")
  H.Report("")
  H.Report("","=== SUSPICIOUS files in paks: {")
  
  -- print/Report list of SUSPICIOUS
  local printLimit = 10
  local printCount = 0
  local pakName = ""
  local notDone = true
  for i=1,#suspiciousTable do
    if pakName ~= suspiciousTable[i][1] then
      pakName = suspiciousTable[i][1]
      notDone = true
      printCount = 0 -- reset
      IsTooMany = false -- reset
    end

    if notDone then
      H.printf("  >> "..H._zWHITEonDARKCYAN.." %s "..H._zDEFAULT,pakName)
      H.Report("",[[ >> "]]..pakName..[["]])
      notDone = false
    end
    
    printCount = printCount + 1
    if printCount <= printLimit then
      H.printf("        - %s",suspiciousTable[i][2])
    elseif not IsTooMany then
      print("   ... Too many, see REPORT.lua")
      IsTooMany = true
    end
    H.Report("","     - "..suspiciousTable[i][2])
  end
end

H.Report("","}")
H.Report("")

-- H.WFAK("BEFORE delete _O folder")

H.DeleteDir([[.\_O]])

local doneIn = " in "..H.dClock(os.clock() - sTime)

print("")
H.Report("")
if IsDoSuspicious then
  if count > 0 or countSuspicious > 0 then
    print("   === "..H._zWHITEonDARKCYAN.."  OUTDATED/SUSPICIOUS detection done"..doneIn.." ("..countPaks.." paks)"..H._zDEFAULT.." ===")
    if countNotUnpacked > 0 then
      print(strformat("          - "..H._zBLACKonYELLOW.." %5d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ paks could not be completely unpacked, see above ]]..H._zDEFAULT,countNotUnpacked))
    end
    print(strformat("          - "..H._zBLACKonYELLOW.." %5d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ OUTDATED file(s): >>> you need to recreate pak(s) ]]..H._zDEFAULT,countOutdated))
    print(strformat("          - "..H._zBLACKonYELLOW.." %5d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ SUSPICIOUS file(s): >>> you may need to recreate file(s)/pak(s) ]]..H._zDEFAULT,countSuspicious))
    print("  "..H._zWHITEonDARKCYAN.." See also "..H._zDEFAULT..H._zBLACKonYELLOW.." REPORT.lua "..H._zDEFAULT..H._zWHITEonDARKCYAN.." for the full list of OUTDATED/SUSPICIOUS file(s) "..H._zDEFAULT)
    
    H.Report("","  ===  OUTDATED/SUSPICIOUS detection done"..doneIn.." ("..countPaks.." paks)".."  ===")
    if countNotUnpacked > 0 then
      H.Report("","         - "..countNotUnpacked.." paks could not be completely unpacked, see above" )
    end
    H.Report("","         - "..countOutdated.." OUTDATED file(s): >>> you need to recreate pak(s)" )
    H.Report("","         - "..countSuspicious.." SUSPICIOUS file(s): >>> you may need to recreate file(s)/pak(s)" )
  else
    print(H._zBRIGHTGREEN.."    OUTDATED/SUSPICIOUS detection done"..doneIn..", "..H._zDEFAULT..H._zBLACKonYELLOW.." NO OUTDATED/SUSPICIOUS file "..H._zDEFAULT..H._zBRIGHTGREEN..[[ found in paks]]..H._zDEFAULT)
    H.Report("",[[<<< NO OUTDATED/SUSPICIOUS file to report from paks >>>]])
  end

  H.Report("","============================ DONE OUTDATED/SUSPICIOUS FILE CHECKING ===================================}\n}")
else
  if count > 0 then
    print("   === "..H._zWHITEonDARKCYAN.."  OUTDATED detection done"..doneIn.." ("..countPaks.." paks)"..H._zDEFAULT.." ===")
    if countNotUnpacked > 0 then
      print(strformat("          - "..H._zBLACKonYELLOW.." %5d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ paks could not be completely unpacked, see above ]]..H._zDEFAULT,countNotUnpacked))
    end
    if countOutdated > 0 then
      print(strformat("          - "..H._zBLACKonYELLOW.." %5d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ OUTDATED file(s): >>> you may need to recreate pak(s) ]]..H._zDEFAULT,countOutdated))
    else
      print(strformat("          - "..H._zBLACKonYELLOW.." %5d "..H._zDEFAULT..H._zWHITEonDARKCYAN..[[ OUTDATED file ]]..H._zDEFAULT,countOutdated))
    end
    print("  "..H._zWHITEonDARKCYAN.." See also "..H._zDEFAULT..H._zBLACKonYELLOW.." REPORT.lua "..H._zDEFAULT..H._zWHITEonDARKCYAN.." for the full list of OUTDATED file(s) "..H._zDEFAULT)
    
    H.Report("","}}")
    H.Report("","  ===  OUTDATED detection done"..doneIn.." ("..countPaks.." paks)".."  ===")
    if countNotUnpacked > 0 then
      H.Report("","         - "..countNotUnpacked.." paks could not be completely unpacked, see above" )
    end
    if countOutdated > 0 then
      H.Report("","         - "..countOutdated.." OUTDATED file(s): >>> you may need to recreate pak(s)" )
    else
      H.Report("","         - "..countOutdated.." OUTDATED file" )
    end
  else
    print(H._zBRIGHTGREEN.."    OUTDATED detection done"..doneIn..", "..H._zDEFAULT..H._zBLACKonYELLOW.." NO OUTDATED file "..H._zDEFAULT..H._zBRIGHTGREEN..[[ found in paks]]..H._zDEFAULT)
    H.Report("",[[<<< NO OUTDATED file to report from paks >>>]])
  end

  H.Report("","============================ DONE OUTDATED FILE CHECKING ===================================\n")
end

local IsBadcaseExtension = false
for i=1,#outdatedEntries do
  local s = outdatedEntries[i][2]
  if s:upper():find(".PAK",1,true) then
    local pos,posEnd = s:upper():find(".PAK",1,true)
    if s:sub(pos,posEnd) ~= ".pak" then
      IsBadcaseExtension = true
      H.Report("",s.." extension is NOT lowercase, NMS will not use it!","NOTICE")
      for j=i+1,#outdatedEntries do
        if outdatedEntries[j][2]:upper() == s:upper() then
          -- remove duplicate
          outdatedEntries[j][2] = ""
        end
      end
    end
  end
end
if IsBadcaseExtension then
  print(">>> "..H.gcNOTICE.." [NOTICE] Some mod .pak extensions are UPPERCASE in PCBANKS\\MODS folder, NMS will NOT USE those mods!!"..H._zDEFAULT)
end

print()

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
