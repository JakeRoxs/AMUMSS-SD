-- ****************************************************
-- main
-- ****************************************************

--arg[1] == path to REPORT.lua
--arg[2] == path to MODBUILDER
--arg[3] == a message --not used
--arg[4] == 1 (check NMS MODS for conflict)
--arg[5] == 1 (called from _Check_CONFLICTS_in_MODS.bat)

if H == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
H.pv(">>>     In CollapseMODS.lua")
H.gfilePATH = arg[1] --used by LoadHelpers.Report()
THIS = "In CollapseMODS: "

local string = string
  local strsub = string.sub
  local strgsub = string.gsub
  local strfind = string.find
  local strlen = string.len -- much better to use #, if you can
  local strupper = string.upper
  local strrep = string.rep
  local strformat = string.format
  local strmatch = string.match
local print = print
local tostring = tostring
local tonumber = tonumber
local type = type
local table = table
local math = math
local os = os

local LDebug = LDebug

-- os.execute([[cmd.exe /c for /f "delims=" %%I in ('dir /s /b /ad ^| sort /r') do echo. "%%I"]])
-- H.WFAK()

-- print("          lfs = "..lfs.currentdir())
-- print("AAAAAA arg[1] = ["..tostring(arg[1]).."]")
-- print("AAAAAA arg[2] = ["..tostring(arg[2]).."]")
-- print("AAAAAA arg[3] = ["..tostring(arg[3]).."]")
-- print("AAAAAA arg[4] = ["..tostring(arg[4]).."]")
-- print("AAAAAA arg[5] = ["..tostring(arg[5]).."]")

-- -- H.Report(arg[3])
-- local LogTable = H.ParseTextFileIntoTable(arg[1]..[[REPORT.lua]])

-- %_bCheckMODSconflicts% EQU 1 >>> Y both MODS and Scripts
-- %_bCheckMODSconflicts% EQU 2 >>> None
-- %_bCheckMODSconflicts% EQU 3 >>> MODS only
-- %_bCheckMODSconflicts% EQU 4 >>> Scripts only

-- local IsCheckMODSconflicts   = (arg[4] == "1") or (arg[4] == "3")
-- local IsCheckSCRIPTconflicts = (arg[4] == "1") or (arg[4] == "4")

-- local IsCalledFromCheckConflictsInMODS = (arg[5] == "1")

local sTime = os.clock()

local MODSloadOrder = H.ParseTextFileIntoTable([[MODS_Report_list.txt]])

-- get file contant of GAMEDATA\MODS
-- H.printf("H.gNMS_MODS_FOLDER = [%s]",H.gNMS_MODS_FOLDER) -- includes \
local MODSlist = H.ListDir(MODSlist, strsub(H.gNMS_MODS_FOLDER,1,-2), true, true)

local nmsFile = {}
for i=1,#MODSlist do
  local tmp = MODSlist[i]:gsub(H.gNMS_MODS_FOLDER,"")
  -- H.printf("%3d: [%s]",i,tmp)
  
  local mod,file = strmatch(tmp,[[^(.-)\(.+)]])
  nmsFile[#nmsFile+1] = {mod,file}
  -- H.printf("   %3d: %50s ==> %s",i,mod,file)
end

-- -- count # of EXML in sub-folders
-- local subDirEXMLcount = {}
-- for i=1,#nmsFile do
  
-- end

-- print("")

local MODSdirList = H.GetMainDirList(H.gNMS_MODS_FOLDER,true)

-- for i=1,#MODSdirList do
  -- -- H.printf("MODSdirList[%d] = [%s]",i,MODSdirList[i])
-- end
-- print("")

local pattern = [[[%d%?]+%s[%?%+%-]+%s(.+)]]
local CollapsedMBINfolder = [[AMUMSS Collapsed MBIN]]

function CollapseMBINFolders(ListOfDirToCollapse, IsFoldOld)
  -- if H.IsDirExist(H.gNMS_MODS_FOLDER..CollapsedMBINfolder) then
    -- if IsFoldOld then
      -- os.rename(H.gNMS_MODS_FOLDER..CollapsedMBINfolder,H.gNMS_MODS_FOLDER..CollapsedMBINfolder..[[_OLD]])
    -- else
      -- H.DeleteDir(H.gNMS_MODS_FOLDER..CollapsedMBINfolder)
    -- end
  -- end
  H.mkdir(H.gNMS_MODS_FOLDER..CollapsedMBINfolder)
  
  -- local param = [[/s /y /h /j]] -- with folders and sub-folders
  -- local paramEXT = [[/s /y /h /j /EXCLUDE:xcopy_excludeEXML.txt]] -- with folders and sub-folders
  local Roboparam = [[/S /V /R:1 /NS /NDL /NP /NC /NJS /NJH /MT:12]]
  
  -- from Pr high->low
  for i=#ListOfDirToCollapse,1,-1 do
    -- H.printf("==> MODSloadOrder[%d] = [%s]",i,ListOfDirToCollapse[i])
    local modFolderName = strmatch(ListOfDirToCollapse[i],pattern)
    -- H.printf("    modFolderName = [%s]",tostring(modFolderName))
    -- copying folder content and deleting collapsed folders that have no EXML
    -- last MBIN wins
    -- if modFolderName then
      H.RobocopyDir(H.gNMS_MODS_FOLDER..modFolderName, H.gNMS_MODS_FOLDER..CollapsedMBINfolder, Roboparam..[[ /MOVE /XF *.EXML locTable.MXML]], false)
    -- end
  end
end

local CollapsedEXMLfolder = [[AMUMSS Collapsed EXML]]

function CollapseEXMLFolders(ListOfDirToCollapse, IsFoldOld)
  -- if H.IsDirExist(H.gNMS_MODS_FOLDER..CollapsedEXMLfolder) then
    -- if IsFoldOld then
      -- os.rename(H.gNMS_MODS_FOLDER..CollapsedEXMLfolder,H.gNMS_MODS_FOLDER..CollapsedEXMLfolder..[[_OLD]])
    -- else
      -- H.DeleteDir(H.gNMS_MODS_FOLDER..CollapsedEXMLfolder)
    -- end
  -- end
  -- H.mkdir(H.gNMS_MODS_FOLDER..CollapsedEXMLfolder)
  
  -- local param = [[/s /y /h /j]] -- with folders and sub-folders
  -- local paramEXT = [[/s /y /h /j /EXCLUDE:xcopy_excludeEXML.txt]] -- with folders and sub-folders
  -- local Roboparam = [[/S /V /R:1 /NS /NDL /NP /NC /NJS /NJH /MT:12]]
  
  -- local trackHandledEXML = {}
  local exmlFolderName = CollapsedEXMLfolder.."_"
  local exmlFolderCounter = 99 -- that should be enough :)
  local exmlFolders = {}
  
  local param = [[/s /y /h /j]] -- with folders and sub-folders

  -- for i=#ListOfDirToCollapse,1,-1 do
    -- H.printf("%3d: [%s]",i,ListOfDirToCollapse[i])
    -- local modFolderName = strmatch(ListOfDirToCollapse[i],pattern)
    -- H.printf("    modFolderName = [%s]",modFolderName)
  -- end
  -- H.WFAK()
  
  local CMf = strupper(CollapsedMBINfolder)
  local CEf = strupper(exmlFolderName)
  -- from Pr high->low
  for i=#ListOfDirToCollapse,1,-1 do
    -- H.printf("==> MODSloadOrder[%d] = [%s]",i,ListOfDirToCollapse[i])
    local modFolderName = strmatch(ListOfDirToCollapse[i],pattern)
    -- H.printf("modFolderName = [%s]",modFolderName)
   
    if (modFolderName == CMf or strfind(modFolderName,CEf..[[%d+]])) then
      -- H.printf("  ==> Skipping modFolderName = [%s]",modFolderName)
    
    elseif H.IsDirExist(H.gNMS_MODS_FOLDER..modFolderName) then
      -- this sub-folder contains EXML files and possibly a LocTable.MXML
      -- H.printf("  ==> Process modFolderName = [%s]",modFolderName)
      local EXMLlist = H.ListDir(EXMLlist, H.gNMS_MODS_FOLDER..modFolderName, false, true)
      
      for k=1,#EXMLlist do
        -- H.printf(" - [%s]",EXMLlist[k])
        local file = strgsub(EXMLlist[k], H.gNMS_MODS_FOLDER, ""):gsub(H.escapeMagicString(modFolderName)..[[\]], ""):upper()
        -- H.printf("     [%s]",file)
        
        for m=exmlFolderCounter,1,-1 do
          if not H.IsFileExist(H.gNMS_MODS_FOLDER..exmlFolderName..m..[[\]]..file) then
            -- in case it does not exist yet
            H.mkdir(H.gNMS_MODS_FOLDER..exmlFolderName..m)
            H.CopyFile(EXMLlist[k], H.gNMS_MODS_FOLDER..exmlFolderName..m..[[\]]..file..[[*]], param, false)
            H.DeleteFile(EXMLlist[k], true, true)
            local path = H.GetFolderPathFromFilePath(EXMLlist[k])
            while path ~= strsub(H.gNMS_MODS_FOLDER,1,-2) do
              -- H.printf("  Deleting sub-folder = [%s]",path)
              lfs.rmdir(path)
              path = H.GetFolderPathFromFilePath(path)
            end
            break
          end
        end --for m=exmlFolderCounter,1,-1 do
        
      end --for k=1,#EXMLlist do
    end --if modFolderName
  end --for i=#ListOfDirToCollapse,1,-1 do
  print("")

end
-- H.printf("H.gNMS_MODS_FOLDER = [%s]",strsub(H.gNMS_MODS_FOLDER,1,-2))
-- H.WFAK()
print("")
print("  Please wait...")
print("     === Collapsing MBINs ===")
-- handle MBIN files in Pr order
CollapseMBINFolders(MODSloadOrder,false)

print("     === Collapsing EXMLs ===")
-- next, handle EXML files in Pr order
--   EXML files are the only ones left in the folders
--   delete empty sub-folders
CollapseEXMLFolders(MODSloadOrder,false)
  
-- delete collapsed folders

print("")

H.Report_flush(false,THIS)

H.LuaEndedOk(THIS)
