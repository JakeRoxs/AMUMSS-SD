function GetDotnetPath(outputPath)
  local dotnetList = H.ParseTextFileIntoTable([[.\MODBUILDER\DOTNET.txt]])
  for i=1,#dotnetList do
    local installDrive = ""
    local s = dotnetList[i]
    local searchFor = [[\program files\dotnet\shared\Microsoft.WindowsDesktop.App]]
    local pos = s:upper():find(searchFor:upper(),1,true)
    if pos then
      installDrive = s:sub(pos-2,pos)
      H.WriteToFile(installDrive:upper(),outputPath)
      break
    end
  end
end

if H == nil then dofile([[.\MODBUILDER\LoadHelpers.lua]]) end

outputPath = [[.\MODBUILDER\DotnetPath.txt]]
GetDotnetPath(outputPath)
