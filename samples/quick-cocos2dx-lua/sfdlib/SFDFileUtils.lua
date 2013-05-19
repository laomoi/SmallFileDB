---
--@module sfdlib.SFDFileUtils

local SFDFileUtils = class("SFDFileUtils")


---
--@function [parent=#sfdlib.SFDFileUtils] ctor
--@param #sfdlib.SFDFileUtils self
function SFDFileUtils:ctor()
end




---
--return the  full file path if  exists
--@function [parent=#sfdlib.SFDFileUtils] getFile
--@param #sfdlib.SFDFileUtils self
--@param #string fileName
function SFDFileUtils:getFile(fileName)
	-- for i,dir in ipairs(self._paths) do
	-- 	local fullPath = dir .. '/' .. fileName
	-- 	if io.exists(fullPath) then 
	-- 		return fullPath
	-- 	end
	-- end
	-- return nil
	local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("sfd/" .. fileName)

	if fullPath == fileName then 
		return nil
	end
	return fullPath
end

---
--return the file string content
--@function [parent=#sfdlib.SFDFileUtils] getFileString
--@param #sfdlib.SFDFileUtils self
--@param #string fileFullPath
function SFDFileUtils:getFileString(fileFullPath)
	return io.readfile(fileFullPath)
end


return SFDFileUtils