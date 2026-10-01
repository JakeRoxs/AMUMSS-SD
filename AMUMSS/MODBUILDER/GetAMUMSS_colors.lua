--***************************************************************************************************
function Lprintf(s,...)
  print(string.format(s,...))
end

--***************************************************************************************************
--changes all \\ to \
--changes all / to \
function LNormalizePath(path)
  if path == nil then return path end
  repeat
    path = string.gsub(path,[[/]],[[\]])
    path = string.gsub(path,[[\\]],[[\]])
  until not string.find(path,[[/]],1,true) and  not string.find(path,[[\\]],1,true)
  return path
end

--***************************************************************************************************
function LGetFilenameFromFilePath(pathname)
  local pathname = LNormalizePath(pathname)
  local tmp = string.match(pathname,[[^.+\(.+)$]])
  if tmp == nil then
    return pathname
  end
  return tmp
end

--***************************************************************************************************
function LGetExtensionFromFilePath(pathname)
  local filename = LGetFilenameFromFilePath(pathname)
  return filename:match([[^.+(%..+)$]])
end

--***************************************************************************************************
function LIsFileExist(pathname)
  local filehandle = io.open(pathname,"rb")
  local Exist = (filehandle ~= nil)
  if Exist then filehandle:close() end
  return Exist
end

--***************************************************************************************************
function LWriteToFile(output,pathname)
  local filehandle = nil
  filehandle = io.open(pathname,"w")
  if filehandle then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end


-- ****************************************************
-- main
-- ****************************************************

--we are in MODBUILDER

local LEsc = "" -- hidden Esc char
local LfgPrefix = LEsc.."[38;2;"
local LbgPrefix = LEsc.."[48;2;"
local Lreset = LEsc.."[0m"

-- gcWARNING = "[95;44m[1m"
local LgcNOTICE  = "[97;104m[1m"
local L_zDEFAULT = "[0m"

local configFile = os.getenv("-UseColorConfigFile")
if configFile == "" then
  configFile = [[AMUMSS_colors.cfg]]
else
  -- print(string.format("%s, %s",LGetExtensionFromFilePath(configFile),configFile))
  if not LGetExtensionFromFilePath(configFile) or string.upper(LGetExtensionFromFilePath(configFile)) ~= ".CFG" then
    configFile = configFile..".cfg"
  end
end

-- print("[38;2;255;0;255m[48;2;255;165;0m Hello world "..Lreset)
-- print("[38;5;201m[48;5;214m Hello world "..Lreset)

-- print()
-- print("LOADING configuration file")
-- print(lfs.currentdir())

local whereIsCONFIG = ""
if not LIsFileExist([[.\CONFIG\]]..configFile) then
  whereIsCONFIG = "."
end

dofile(whereIsCONFIG..[[.\CONFIG\]]..configFile)

-- print("")
-- for k,v in pairs(colors) do
  -- Lprintf("  %15s = %s",k,v)
  -- local tmp = string.gsub(v,",",";").."m "..k.." "
  -- print("                   ==> ["..LfgPrefix..tmp..Lreset.."]")
  -- print("                   ==> ["..LbgPrefix..tmp..Lreset.."]")
-- end
-- print("")

-- for use by BUILDMOD.bat
local colorsTmp = {}
local cTmp = {}
local IsColorsTableOk = false
if type(Colors) == "table" then
  IsColorsTableOk = true
  for k,v in pairs(Colors) do
    -- CHECK IF v is a valid RGB value
    local count = 0
    local IsOk = true
    for value in string.gmatch(v,"%d*") do
      count = count + 1
      if count < 4 then
        if not (tonumber(value) >= 0 and tonumber(value) <= 255) then
          Lprintf(LgcNOTICE.." [NOTICE] Value [%s] of '%s' is out-of-range, color is ignored! "..L_zDEFAULT,value,k)
          IsOk = false
          break
        end
      else
        Lprintf(LgcNOTICE.." [NOTICE] '%s' has too many values, color is ignored! "..L_zDEFAULT,k)
        IsOk = false
        break
      end
    end
    
    if count < 3 then
      Lprintf(LgcNOTICE.." [NOTICE] '%s' has too few values, color is ignored! "..L_zDEFAULT,k)
    elseif count == 3 and IsOk then
      colorsTmp[#colorsTmp + 1] = [[set "fg]]..k.."="..LfgPrefix..string.gsub(v,",",";")..[[m"]]
      colorsTmp[#colorsTmp + 1] = [[set "bg]]..k.."="..LbgPrefix..string.gsub(v,",",";")..[[m"]]
      cTmp[k] = true
    end
  end

  LWriteToFile(table.concat(colorsTmp, "\n"),whereIsCONFIG..[[.\MODBUILDER\Colors_result.lua]])
else
  Lprintf(LgcNOTICE.." [NOTICE] 'Colors' of '%s' is not a valid table, configuration file is ignored! "..L_zDEFAULT,configFile)
end

-- for use by BUILDMOD.bat
if IsColorsTableOk then
  if type(UsedColors) == "table" then
    UsedColorsTmp = {}
    for k,v in pairs(UsedColors) do
      local fg = ""
      local bg = ""
      -- v = string.gsub(v,"_","") -- remove underscores
      v = string.gsub(v," ","") -- remove spaces
      
      local pos = string.find(v,[[*]],1,true)
      
      local IsFgOk = true
      local IsBgOk = true
      if pos then
        if pos > 1 then
          fg = string.sub(v,1,pos -1)
          bg = string.sub(v,pos +1)
          IsFgOk = cTmp[fg] ~= nil
          IsBgOk = cTmp[bg] ~= nil
        else
          bg = string.sub(v,2) -- just a background
          IsBgOk = cTmp[bg] ~= nil
        end
      else
        fg = v -- just a foreground
        IsFgOk = cTmp[fg] ~= nil
      end

      -- Lprintf("[%s] = '%s'",fg,tostring(IsFgOk))
      -- Lprintf("[%s] = '%s'",bg,tostring(IsBgOk))

      -- CHECK IF v exists in colorsTmp
      if IsFgOk and IsBgOk then
        if pos then
          if pos > 1 then
            fg = "!fg"..fg.."!"
            bg = "!bg"..bg.."!"
          else
            bg = "!bg"..bg.."!"
          end
        else
          fg = "!fg"..fg.."!"
        end
        UsedColorsTmp[#UsedColorsTmp + 1] = [[set "]]..k..[[=]]..fg..bg..[["]]
      else
        Lprintf(LgcNOTICE.." [NOTICE] Definition of [%s] does not match value(s) from 'Colors' table, '%s' is ignored! "..L_zDEFAULT,v,k)
      end
    end

    LWriteToFile(table.concat(UsedColorsTmp, "\n"),whereIsCONFIG..[[.\MODBUILDER\UsedColors_result.lua]])
  else
    Lprintf(LgcNOTICE.." [NOTICE] 'UsedColors' of '%s' is not a valid table, configuration file is ignored! "..L_zDEFAULT,configFile)
  end
end
