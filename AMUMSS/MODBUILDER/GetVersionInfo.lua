function NMS_VersionInfo(NMS_EXE_PATH)
  -- print("NMS_EXE_PATH = ["..NMS_EXE_PATH.."]")
  local versionId = "not found using NMS.exe"
  local versionIdtype = " (?)"
  local SaveVersion = ""
  
  -- [[Software\Classes\nms\shell\open\command?"???" "%1"??91506???????]]
  -- local SearchFor = [[Software\Classes\nms\shell\open\command]] -- prior to 100408-4.10

-- also found at:
    -- .rsrc:144eeb552 46 00 69 00 6c 00 65 0...    unicode    u"FileVersion"
    -- .rsrc:144eeb56a 00                           ??         00h
    -- .rsrc:144eeb56b 00                           ??         00h
    -- .rsrc:144eeb56c 31 00 30 00 31 00 35 0...    unicode    u"101550"

-- or:
    -- .rsrc:144eeb694 32 00 07 00 01 00            StringInfo
    -- .rsrc:144eeb69a 50 00 72 00 6f 00 64 0...    unicode    u"ProductVersion"
    -- .rsrc:144eeb6b8 31 00 30 00 31 00 35 0...    unicode    u"101550"

  local SearchFor = ""
  
  local filehandle = io.open(NMS_EXE_PATH,"rb")
  if filehandle then  
    local data = filehandle:read("a")
    filehandle:close()    

    -- SAVE VERSION
    SearchFor = [[44887DA8488D15]] -- from 137028 up
    -- H.printf("SearchFor = %s",SearchFor)
    
    local SearchForHex = H.fromHex(SearchFor)
    -- H.printf("SearchForHex = %s",SearchForHex)

    dataPos = string.find(data,SearchForHex,1,true)
    -- H.printf("dataPos %s",tostring(dataPos))
    if dataPos then
      SaveVersion = tostring(tonumber(H.toHex(string.reverse(string.sub(data,dataPos - 4,dataPos - 4 + 1))),16))
      -- H.printf("Save Version %s",SaveVersion)
    end

    -- NMS VERSION
    local d = string.gsub(data,[[%c]],"") -- strip control characters

    SearchFor = [[ProductVersion]] -- from 137028 up
    dataPos = string.find(d,SearchFor,1,true)
    if dataPos then
      versionId = string.sub(d,dataPos + #SearchFor + 0,dataPos + #SearchFor + 5)
      if tonumber(versionId) then
        versionIdtype = " (D)"
        return versionId, versionIdtype, SaveVersion
      end
    end
    
    SearchFor = [[%NAME%]] -- from 100408-4.10 up
    dataPos = string.find(data,SearchFor,1,true)
    if dataPos then
      -- < 100408-4.10
      versionId = string.sub(data,dataPos + #SearchFor + 13,dataPos + #SearchFor + 17)
      if tonumber(versionId) then
        versionIdtype = " (C)"
        return versionId, versionIdtype, SaveVersion
      end
      
      -- from >= 100408-4.10 and < 128610-5.10 and > 131733-5.22
      versionId = H.trim(string.sub(data,dataPos + #SearchFor + 2,dataPos + #SearchFor + 7))
      if tonumber(versionId) then
        versionIdtype = " (B)"
        return versionId, versionIdtype, SaveVersion
      end
    end
    
    SearchFor = [[D_DEBUG]] -- from 128610-5.10
    dataPos = string.find(data,SearchFor,1,true)
    if dataPos then
      versionId = H.trim(string.sub(data,dataPos - 8,dataPos -1)):gsub("\0","") -- from 128610-5.10
      versionIdtype = " (A)"
    end    
  end
  
  local v = tonumber(versionId)
  if v then
    versionId = v
  else
    versionId = "Unknown"
  end
  
  return versionId, versionIdtype, SaveVersion
end

function NMS_GAMEPASS_VersionInfo(GAMEPASS_Info_path)
  -- print("GAMEPASS_Info_path = ["..GAMEPASS_Info_path.."]")
  local versionId = "???"
  
  -- From MicrosoftGame.config
  --   <Identity Name="HelloGames.NoMansSky" Publisher="CN=E17FC9C0-77E1-4CDD-8AE0-E634942431EE" Version="3.991.26223.0" />
  -- From appxmanifest.xml
  --   <Identity Name="HelloGames.NoMansSky" Publisher="CN=E17FC9C0-77E1-4CDD-8AE0-E634942431EE" Version="3.991.26223.0" ProcessorArchitecture="x64" />

  local SearchFor = [[Publisher="CN=E17FC9C0-77E1-4CDD-8AE0-E634942431EE"]]

  local infoTable = H.ParseTextFileIntoTable(GAMEPASS_Info_path)
-- H.printf("currentdir = [%s]",lfs.currentdir())
-- H.printf("GAMEPASS_Info_path = [%s]",GAMEPASS_Info_path)
-- H.printf("#infoTable = %d",#infoTable)
  for i=1, #infoTable do
-- H.printf("%d: %s",i,infoTable[i])
    if infoTable[i]:find(SearchFor,1,true) then
      local found = false
      for j=i+1, #infoTable do
        local _,pos = infoTable[j]:find("Version=",1,true)
        if pos then
          versionId = infoTable[j]:sub(pos+2)
          versionId = versionId:sub(1,versionId:find([["]],1,true)-1)
          found = true
          break
        end
      end
      if found then
        break
      end
    end
  end
  
  if versionId == "???" then
    versionId = "not found for GAMEPASS"
  end
  
  return versionId
end

-- ****************************************************
-- main
-- ****************************************************

--we are in AMUMSS folder

--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER
--arg[3] == optional, do colors

local startPath = lfs.currentdir()
-- print("Start dir:",startPath)

lfs.chdir(arg[2])

IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile([[LoadHelpers.lua]]) end
H.pv(">>>     In GetVersionInfo.lua")
H.gfilePATH = arg[1] --for Report()
THIS = "In GetVersionInfo: "

if arg[3] ~= "Y" then
  H._zBRIGHTGREEN   =""
  H._zDEFAULT       =""
end

-- check if we need to update the info
H.DeleteFile(H.PCBanks_LISTdateTime,false,true)

local currentPath = lfs.currentdir()
-- print("D:",currentPath)
-- print("C:",H.gNMS_PCBANKS_FOLDER_PATH)

local IsToUpdate = false
if H.IsFileExist(H.NMS_VERSION_CREATED) then
  if H.IsFileExist([[NMS_versionId.txt]]) and H.IsFileExist([[NMS_SaveVersion.txt]]) then
    -- if (lfs.chdir(H.gNMS_PCBANKS_FOLDER_PATH)) then
      -- -- print("A:",lfs.currentdir())
      -- H.CopyFile(currentPath..[[\]]..H.NMS_VERSION_CREATED, H.gNMS_PCBANKS_FOLDER_PATH.."*", "/y /h /j /r", true)
      -- -- H.WFAK("AFTER COPY")
      -- local FileTable = H.GetFileCreationByDate(string.sub(H.gNMS_PCBANKS_FOLDER_PATH,1,-2))
      -- H.DeleteFile(H.NMS_VERSION_CREATED)

      
      local lastModifNMS_exe, errNMS_exe = lfs.attributes(H.gNMS_Binary_PATH, 'modification')
      -- if errNMS_exe then
          -- print(errNMS_exe)
      -- else
          -- print(H.gNMS_Binary_PATH, os.date("%c", lastModifNMS_exe), lastModifNMS_exe)
      -- end

      local lastModifNMSVersion, errNMSVersion = lfs.attributes(startPath..[[\MODBUILDER\NMS_versionId.txt]], 'modification')
      -- if errNMSVersion then
          -- print(errNMSVersion)
      -- else
          -- print([[NMS_versionId.txt]], os.date("%c", lastModifNMSVersion), lastModifNMSVersion)
      -- end
      
      if errNMS_exe or errNMSVersion then
        print("Problem getting last modification datetime!")
      else
        if lastModifNMSVersion >= lastModifNMS_exe then
          -- print("NMS version is up-to-date")
          IsToUpdate = true
        else
          -- print("No need to update info")
        end
      end
      
      -- -- H.WFAK("AFTER FileList")
      -- if FileTable[1] == H.NMS_VERSION_CREATED then
        -- -- print("No need to update info")
        -- IsToUpdate = false
      -- end
    -- end
  end
end

lfs.chdir(startPath)
-- print("Y:",lfs.currentdir())
-- H.printf("IsToUpdate = %s",tostring(IsToUpdate))
-- H.WFAK()
-- END: check if we need to update the info

local versionId = ""
local SaveVersion = ""
local versionIdtype = ""

if not IsToUpdate then
  -- NMS_FOLDER = H.LoadFileData([[.\CONFIG\NMS_FOLDER.txt]])
  -- NMS_FOLDER = string.gsub(NMS_FOLDER,"\n","") --remove line break if any
  -- -- H.printf("NMS_FOLDER = [%s]",NMS_FOLDER)

  -- gNMS_BINARIES_FOLDER_PATH = NMS_FOLDER..[[\BINARIES\]]
  -- -- print("Z:",gNMS_BINARIES_FOLDER_PATH)
  -- NMS_EXE = [[NMS.exe]]

  -- for Steam and GoG
  versionId, versionIdtype, SaveVersion = NMS_VersionInfo(H.gNMS_Binary_PATH)

  if versionId == "???" or versionId == "not found" then
    -- print("  "..H._zBRIGHTGREEN.."===> NMS version "..versionId..H._zDEFAULT)
    -- NMS.exe was not accessible
    -- let us see if this is GamePass
    gNMS_GAMEPASS_FOLDER_PATH = NMS_FOLDER
    -- could use appxmanifest.xml or MicrosoftGame.config
    NMS_GAMEPASS_info = [[\MicrosoftGame.Config]]
    versionId = NMS_GAMEPASS_VersionInfo(gNMS_GAMEPASS_FOLDER_PATH..NMS_GAMEPASS_info)
    -- for DEBUG
    -- versionId = NMS_GAMEPASS_VersionInfo(NMS_GAMEPASS_info)
    versionIdtype = " (G)"
    SaveVersion = ""
  end

  H.WriteToFile(versionId,arg[2]..[[NMS_versionId.txt]])
  H.WriteToFile(SaveVersion,arg[2]..[[NMS_SaveVersion.txt]])
  
  if string.find(versionId,"Unknown",1,true) == nil then
    H.WriteToFile("",arg[2]..H.NMS_VERSION_CREATED)
  end

  -- H.Report("","NMS version "..versionId)
  -- H.Report_flush(false,THIS)

else
  -- print("Loading info...["..arg[2].."]")
  -- print("X:",lfs.currentdir())
  versionId = H.LoadFileData(arg[2]..[[NMS_versionId.txt]])
  SaveVersion = H.LoadFileData(arg[2]..[[NMS_SaveVersion.txt]])
  versionIdtype = ""
end

print("  "..H._zBRIGHTGREEN.."===> NMS version "..versionId.." ("..SaveVersion..")"..versionIdtype..H._zDEFAULT)

H.LuaEndedOk(THIS)
