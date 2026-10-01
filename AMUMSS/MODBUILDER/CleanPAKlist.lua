function CleanPAKList(filename)
  local LineTable = H.ParseTextFileIntoTable(filename)
  local TempTable = {}
  
  for i=1,#LineTable do
    local text = LineTable[i]
    -- if string.find(text,[[.DDS ]],1,true) 
        -- or string.find(text,[[.SPV ]],1,true)
        -- or string.find(text,[[.WEM ]],1,true)
        -- or string.find(text,[[.FNT ]],1,true)
        -- -- or string.find(text,[[.BIN ]],1,true)
        -- or string.find(text,[[.BNK ]],1,true)
        -- or string.find(text,[[.TXT ]],1,true) then
    if text ~= "" then
      local ext = string.sub(text,-4)
      if ext and ext ~= "" then
        ext = string.upper(ext)
        if ext == [[.DDS]] 
            or ext == [[.SPV]]
            or ext == [[.WEM]]
            or ext == [[.FNT]]
            -- or ext == [[.BIN]]
            or ext == [[.BNK]]
            or ext == [[.TXT]] then
        else
          TempTable[#TempTable+1] = text
        end
      end
    else
      TempTable[#TempTable+1] = ""
    end
  end
  
  
  local text = H.ConvertLineTableToText(TempTable)
  H.WriteToFile(text, filename)
end

-- -- PROCESSING THIS IS VERY LONG, TRY NOT TO USE IT
-- -- just used to check if we could use Filenames only to find correct path to pak files
-- local function CheckDuplicateFilenames(pakList)
-- -- ****************************  FilenameDuplicates.txt ******************************
  -- print("Executing CheckDuplicateFilenames()")
  -- H.WriteToFile("Executing CheckDuplicateFilenames()\n",LocalFolder.."FilenameDuplicates.txt")

  -- local function printout(DoPrint,...)
    -- if DoPrint then print(...) end
    -- H.WriteToFileAppendEXT(LocalFolder.."FilenameDuplicates.txt",...)    
  -- end
  
  -- local TempTable2 = H.ParseTextFileIntoTable(pakList)
  -- print("Executing TempTable2...")
  
  -- local tmp = {}
  -- for i=1,#TempTable2 do
    -- if TempTable2[i] ~= "" then
      -- local pos = string.find(TempTable2[i]," (",1,true)
      -- if pos then
        -- local filename = H.GetFilenameFromFilePath(string.sub(TempTable2[i],1,pos - 1))
        -- if tmp[filename] then
          -- -- already exist
          -- printout(false,string.format([[%4u: /%s]],i,filename))
        -- else
          -- -- does not yet exist
          -- tmp[filename] = true
        -- end
      -- end
    -- end
  -- end
-- end
-- ****************************  end FilenameDuplicates.txt ******************************

-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER

IsLightLoadHelper = true -- must be GLOBAL
LocalFolder = ""
if H == nil then dofile(LocalFolder.."LoadHelpers.lua") end
H.pv(">>>     In CleanPAKList.lua")
THIS = "In CleanPAKList: "

-- H.gfilePATH = "..\\" --for Report()

THIS = "In CleanPAKList: " --Check for THIS in code before changing this string

-- only used for information, NOT REQUIRED
-- DO NOT USE
-- CheckDuplicateFilenames(LocalFolder.."pak_list.txt")

CleanPAKList(LocalFolder.."pak_list.txt")
H.LuaEndedOk(THIS)

