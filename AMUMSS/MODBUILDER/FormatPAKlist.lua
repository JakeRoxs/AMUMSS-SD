function FormatPAKList(filename)
  local LineTable = H.ParseTextFileIntoTable(filename)
  local TempTable = {}
  local FullTempTable = {}
  local badFile = false
  
  badFile = (#LineTable == 0)

  for i=1,#LineTable do
    local text = LineTable[i]
    if string.sub(text,1,7) == "Listing" then
      TempTable[i] = text.." = {"
      FullTempTable[i] = text
--   elseif string.sub(text,1,1) ~= " " then
    elseif H.trim(text) ~= "" then
      -- local start = string.find(text," (",1,true)
      -- local start = string.find(text," ",1,true)
      -- if start == nil then
        -- badFile = true
        -- break
      -- end
      -- local info = string.sub(string.gsub(text,[[/]],[[\]]),1,start-1)
      local info = string.gsub(text,[[/]],[[\]])
      TempTable[i] = [["]]..info..[[",]]
      FullTempTable[i] = info
    else
      TempTable[i] = H.trim(text).."}"
      FullTempTable[i] = text
    end
  end
  TempTable[#TempTable+1] = "}"
  
  if not badFile then
    local text = H.ConvertLineTableToText(TempTable)
    H.WriteToFile(text, filename.."Pretty.lua")
    
    local text = H.ConvertLineTableToText(FullTempTable)
    H.WriteToFile(text,"Full_"..filename)
  end
  return badFile
end

function GetPakList(filename)
  local LineTable = H.ParseTextFileIntoTable(filename)
  local TempTable = {}
  
  --pass one, remove all file names and remove duplicate directories in the same .pak only
  local tempInfo = ""
  for i=1,#LineTable do
    local text = LineTable[i]
    if string.sub(text,1,7) == "Listing" then
      TempTable[#TempTable+1] = text.." = {"
      -- print(text)
--    elseif string.sub(text,1,1) ~= " " then
    elseif H.trim(text) ~= "" then
      local info = H.getPath(text)
      -- local start = string.find(text,[[\]],-1,true)
      -- local info = string.sub(string.gsub(text,[[/]],[[\]]),1,start)
      if info and info ~= tempInfo then
        TempTable[#TempTable+1] = "[["..info.."]],"
        tempInfo = info
        -- print(info)
      end
    else
      TempTable[#TempTable+1] = H.trim(text).."}"
    end
  end
  TempTable[#TempTable+1] = "}"
  
  --create a list of unique directory
  local TempUniqueDirTable = {}
  local tmp = {}
  for i=1,#TempTable do
    local text = TempTable[i]

    if text == "" or string.sub(text,1,7) == "Listing" or string.sub(text,1,1) == "}" then
      --skip it
    else
      local s = string.sub(text,3,-3) --keep the last ']', why??

      if tmp[s] then
        -- already exist, skip  it
      else
        tmp[s] = true
        TempUniqueDirTable[#TempUniqueDirTable+1] = s
      end
    end
  end  
  
  table.sort(TempUniqueDirTable)
  
  local text = H.ConvertLineTableToText(TempUniqueDirTable)
  H.WriteToFile(text, "pak_UniqueDir.txt")
    
  text = H.ConvertLineTableToText(TempTable)
  H.WriteToFile(text, "pak_Dir.txtPretty.lua")
  
end

-- ****************************************************
-- MAIN
-- ****************************************************

--we are in MODBUILDER

IsLightLoadHelper = true -- must be GLOBAL
LocalFolder = ""
if H == nil then dofile(LocalFolder.."LoadHelpers.lua") end
H.pv(">>>     In FormatPAKlist.lua")
THIS = "In FormatPAKlist: " --Check for THIS in code before changing this string

-- H.gfilePATH = "..\\" --for Report()

-- *******************
-- ********** IF YOU WANT TO TEST, PLEASE execute PSARC_LIST_PAKS.BAT
-- *******************

badFile = FormatPAKList(LocalFolder.."pak_list.txt")
if not badFile then
  GetPakList(LocalFolder.."Full_pak_list.txt")
else
  print(H.gcERROR..[[>>> [ERROR] AMUMSS could not list NMS paks content, check access to folder GAMEDATA]]..H._zDEFAULT)
  H.Report("",[[>>> AMUMSS could not list NMS paks content, check access to folder GAMEDATA]],"ERROR")          
end

H.LuaEndedOk(THIS)
