IsLightLoadHelper = true -- must be GLOBAL
if H == nil then dofile("LoadHelpers.lua") end
H.THIS = "In Get_MODS_List: "

local unknownMsg = [[         ?: Unknown at this time (run game to resolve)]]
if arg[1] == "UpdateNMS" then
  os.execute("cmd.exe /c NMS_Status.bat")
  unknownMsg = [[         ?: Unknown (CANNOT be resolved, BAD mod folder?)]]
end

local ModSettings, ModGeneralSettings = H.GetModsSettings()

-- print(" ==== List ModSettings ====")
-- for k,v in pairs(ModSettings) do
  -- H.printf("==> %s = [%s]",k,v)
  -- if type(v) == "table" then
    -- for k,v in pairs(v) do
      -- H.printf("  - %s = [%s]",k,v)
    -- end
  -- end
-- end
-- H.WFAK("WAITING after H.GetModsSettings()")

if ModGeneralSettings["DisableAllMods"] == "true" then
  print("")
  print(">>> "..H.gcNOTICE..[[ [NOTICE] DisableAllMods is 'true' in No Man's Sky\Binaries\SETTINGS\GCMODSETTINGS.MXML, resetting to 'false' ]]..H._zDEFAULT)
  H.Report("",[[DisableAllMods was 'true' in No Man's Sky\Binaries\SETTINGS\GCMODSETTINGS.MXML, reset to 'false']],"NOTICE")
  
  local ModSettingsXML = H.LoadFileData(H.MODSETTINGS_PATH)
  ModSettingsXML = string.gsub(ModSettingsXML,[["DisableAllMods" value="true"]],[["DisableAllMods" value="false"]])
  H.WriteToFile(ModSettingsXML,H.MODSETTINGS_PATH)
end

local GCMODSETTINGS_currentModifTime = lfs.attributes(H.MODSETTINGS_PATH,"change")

print("")
print(H._zWHITEonDARKCYAN..[[>>> Getting list of mods from GAMEDATA\MODS based on most recent GCMODSETTINGS.MXML... ]]..H._zDEFAULT)
print([[    key: #: ModPriority, ++: Enabled/EnabledVR: ModName]])
print(unknownMsg)

local ListModDir = H.ListDir(ListModDir, H.gNMS_MODS_FOLDER, true, true)
    
-- print("=== Files in GAMEDATA/MODS")
-- for i=1,#ListModDir do
  -- H.printf("   ==> %s",ListModDir[i])
-- end
-- print("===")
-- -- H.WFAK("Waiting: After H.ListDir()...")

local ListOfMODS = {}
local MODS_List = {"FROM MODS"}
-- H.printf("=====================>>> [%s]",H.gNMS_MODS_FOLDER)
for i=1,#ListModDir do
  -- strip MODS path
  ListModDir[i] = string.gsub(ListModDir[i], H.escapeMagicString(H.gNMS_MODS_FOLDER)..[[\]], "")
-- H.printf("   --> [%s]",ListModDir[i])
  
  -- MODS folder names are the MODS
  if string.find(ListModDir[i],[[\]],1,true) then
    --local tmp = string.sub(ListModDir[i], 2)
    local tmp = string.sub(ListModDir[i], 1, string.find(ListModDir[i],[[\]],1,true)-1)
    local TMP = tmp:upper()
-- H.printf("   === [%s]",TMP)
    
    if ListOfMODS[TMP] == nil then
      local priority = " ?"
      local enabled = "?"
      local enabledVR = "?"

      if ModSettings[TMP] ~= nil then
        -- H.printf("TMP = [%s]",tostring(TMP))
        priority = ModSettings[TMP]["ModPriority"]
        if priority == nil then priority = " ?" end
        
        enabled = ModSettings[TMP]["Enabled"]
        if enabled == "true" then
          enabled = "+"
        else
          enabled = "-"
        end
        
        enabledVR = ModSettings[TMP]["EnabledVR"]
        if enabledVR == "true" then
          enabledVR = "+"
        else
          enabledVR = "-"
        end
      end
      
      -- H.printf("   - %2s %s%s: %s",priority,enabled,enabledVR,TMP)
      ListOfMODS[TMP] = string.format("   - %3s %s%s %s",priority,enabled,enabledVR,tmp)
      MODS_List[#MODS_List+1] = "\nListing "..TMP
      MODS_List[#MODS_List+1] = ListModDir[i]:upper()
    else
      MODS_List[#MODS_List+1] = ListModDir[i]:upper()
    end
  end
end

if #MODS_List <= 1 then
  print(" ==> No installed mod detected")
end

local LM = {}
for k,v in pairs(ListOfMODS) do
  LM[#LM+1] = v
end

-- a = [   -  ? ?? AMUMSS COMBINE_1]
-- b = [   -  3 ++ NPC_LANDINGPAD (1)]

local function sortingOrder(a,b)
  -- H.printf("a = [%s]",a)
  -- H.printf("b = [%s]",b)
  local aa = string.sub(a,7,7)
  local bb = string.sub(b,7,7)
  -- H.printf("aa = [%s]",aa)
  -- H.printf("bb = [%s]",bb)
  if aa == "?" and bb ~= "?" then
    return true
  elseif aa ~= "?" and bb == "?" then
    return false
  else
    if a < b then
      return true
    end
  end
  return false
end

-- H.WFAK("Waiting: Before table.sort()...")

table.sort(LM,sortingOrder)

for i=1,#LM do
  -- H._zBRIGHTGREEN..tmp..H._zDEFAULT
  print(LM[i])
end

H.WriteToFile(LM,[[MODS_Report_list.txt]])
H.WriteToFile(MODS_List,[[MODS_pak_list.txt]])

print("")
H.LuaEndedOk(H.THIS)

-- H.WFAK("Waiting: End of Get_Mods_List.lua...")
