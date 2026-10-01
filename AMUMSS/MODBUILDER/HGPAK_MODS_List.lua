if H == nil then dofile("LoadHelpers.lua") end

local ModSettings, ModGeneralSettings = H.GetModsSettings()

print("")
print([[>>> Getting list of mods from GAMEDATA\MODS...]])
print([[    key: #: Priority, ++: Enabled/EnabledVR: ModName]])
print([[         ?: Unknown at this time]])

local ListModDir = H.ListDir(ListModDir, H.gNMS_MODS_FOLDER, true, true)
    
-- print("=== Folders in GAMEDATA/MODS")
-- for i=1,#ListModDir do
  -- H.printf("   ==> %s",ListModDir[i])
-- end
-- print("===")

local ListOfMODS = {}
local MODS_List = {"FROM MODS"}
for i=1,#ListModDir do
  -- strip MODS path
  ListModDir[i] = string.gsub(ListModDir[i], H.gNMS_MODS_FOLDER..[[\]], "")
  -- H.printf("   --> %s",ListModDir[i])
  
  -- MODS folder names are the MODS
  local tmp = string.sub(ListModDir[i]:upper(), 1, string.find(ListModDir[i],[[\]],1,true)-1)
  if ListOfMODS[tmp] == nil then
    local priority = " ?"
    local enabled = "?"
    local enabledVR = "?"

    if ModSettings[tmp] ~= nil then
      -- H.printf("tmp = [%s]",tostring(tmp))
      priority = ModSettings[tmp]["ModPriority"]
      if priority == nil then priority = " ?" end
      
      enabled = ModSettings[tmp]["Enabled"]
      if enabled == "true" then
        enabled = "+"
      else
        enabled = "-"
      end
      
      enabledVR = ModSettings[tmp]["EnabledVR"]
      if enabledVR == "true" then
        enabledVR = "+"
      else
        enabledVR = "-"
      end
    end
    
    H.printf("   - %2s %s%s: %s",priority,enabled,enabledVR,tmp)
    ListOfMODS[tmp] = true
    MODS_List[#MODS_List+1] = "\nListing "..tmp
    MODS_List[#MODS_List+1] = string.gsub(ListModDir[i],tmp..[[\]],"")
  else
    MODS_List[#MODS_List+1] = string.gsub(ListModDir[i],tmp..[[\]],"")
  end
end
if #MODS_List <= 1 then
  print(" ==> No mod detected")
end
H.WriteToFile(MODS_List,[[MODS_pak_list.txt]])

print("")
