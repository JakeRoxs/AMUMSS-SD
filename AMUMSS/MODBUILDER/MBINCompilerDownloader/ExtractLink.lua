function GetURL()
	-- print("In GetURL()")
  local URL = ""
	local line = ""
  local IsSuccess,filehandle = pcall(io.open,"RAW.txt", "r")

  local L_zDEFAULT ="[0m"
  local L_zBRIGHTRED ="[1;91m[1m" 
  
  if not IsSuccess or filehandle == nil then
  -- if true then
    print(L_zBRIGHTRED..[[>>> [WARNING]       It seems you lost internet access OR                      ]]..L_zDEFAULT)
    print(L_zBRIGHTRED..[[>>>           Your AV is blocking curl.exe access to web, create an exception!]]..L_zDEFAULT)
    print(L_zBRIGHTRED..[[>>>           >>> cannot check for updated MBINCompiler.exe and libMBIN.dll...]]..L_zDEFAULT)
    print(L_zBRIGHTRED..[[>>>           Cannot access "https://api.github.com/repos/monkeyman192/MBINCompiler/releases"]]..L_zDEFAULT)
    
    print()
    print("  Directory listing:")
    local path = lfs.currentdir()
    for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
        local f = path..[[\]]..file
        local attr,msg = lfs.attributes(f)
        
        if attr then      
          if attr.mode == "file" and not string.find(file,".lnk",1,true) then
            H.printf("    - (%8s, %s, %s) %s", attr.size, os.date("%x %X",attr.modification), attr.permissions, f)
          end          
        end
      end
    end
    
    LWriteToFile("","temp1.txt")
    LWriteToFile("","temp2.txt")
    LWriteToFile("","RAW.txt")
    H.WFAK("Press any key to continue...")
    return
  end
  
  local compilerCount = 0

  -- if [["prerelease": true,]] then experimental
  -- if [["prerelease": false,]]  then public
  --   if 1st compiler then experimental AND public
  
  local experimental = false
  local public = false
  local line = ""
  local lineCount = 0
  
  repeat
		line = filehandle:read("l")
		if line then
      lineCount = lineCount + 1
      
      if string.find(line, [["prerelease": false,]],1,true) then
        if compilerCount == 0 then
          experimental = true
          public = true
          -- print("found 1st compiler and >PUBLIC / EXPERIMENTAL< at "..lineCount)
        else
          public = true
          -- print("found 1st compiler and >PUBLIC< at "..lineCount)
        end
      elseif string.find(line, [["prerelease": true,]],1,true) then
        if compilerCount == 0 then
          experimental = true
          -- print("found 1st compiler and >experimental ONLY< at "..lineCount)
        end
      end
      
			if string.find(line, "/monkeyman192/MBINCompiler/releases/download/",1,true) and string.find(line, "MBINCompiler.exe",1,true) then				
        -- print("   found a MBINCompiler.exe at "..lineCount)
				compilerCount = compilerCount + 1
        local start_pos = string.find(line,'"https',1,true)
				if start_pos then 
          URL = string.sub(line,start_pos+1,-2)
				end	
				
        if compilerCount == 1 then
          -- print("   >>> found public compiler.exe with compilerCount == 1 at "..lineCount)
          -- print("       "..URL)
          LWriteToFile(URL,"temp1.txt")
          
          if public then
            -- print("   >>> setting previous compiler.exe to public at "..lineCount)
            -- print("       "..URL)
            LWriteToFile(URL,"temp2.txt")
            break
          end
          compilerCount = compilerCount + 1
          
        elseif public then
          -- print("   >>> found compiler.exe with compilerCount > 1 AND public at "..lineCount)
          -- print("       "..URL)
          LWriteToFile(URL,"temp2.txt")
          break
        end        
			end
		end
	until line == nil
  
  filehandle:close()
end

function LWriteToFile(output, file)
  local filehandle = assert(io.open(file, "w"),"io.open: Cannot open tempX.txt to write")
  if filehandle then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

if H == nil then dofile("..\\LoadHelpers.lua") end
if H == nil then dofile("LoadHelpers.lua") end
GetURL()

