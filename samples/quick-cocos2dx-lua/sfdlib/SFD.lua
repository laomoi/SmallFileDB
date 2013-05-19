-----
-- SFD, small file db, this class is sth like the db connection manages all tables
-- @module sfdlib.SFD


local SFD = class("SFD")

---
-- @field  [parent=#sfdlib.SFD] sfdlib.SFDFileUtils#sfdlib.SFDFileUtils _fileUtils

--- 
-- @field	[parent=#sfdlib.SFD] #table _tables

---
-- @field  [parent=#sfdlib.SFD] #table _tableFactory


---
--@function [parent=#sfdlib.SFD] ctor
--@param #sfdlib.SFD self
function SFD:ctor()
	self._fileUtils = require("sfdlib.SFDFileUtils").new()
	self._tables = {}
	self._tableFactory = {}
end

---
--@function [parent=#sfdlib.SFD] addTable
--@param #sfdlib.SFD self
--@param #string t
--@param #string clTable
--@param #string clRecord
function SFD:addTable(t, clTable, clRecord)
	self._tableFactory[t] = {clTable, clRecord}
end




---
--@function [parent=#sfdlib.SFD] getTable
--@param #sfdlib.SFD self
--@param #string t
function SFD:getTable(t)
	if self._tables[t] == nil then 
		local cls = self._tableFactory[t]
		if cls == nil  then 
			error(t .. " has no creator")
			return nil
		end


		local clTable = cls[1]
		local clRecord = cls[2]
		self._tables[t] = require(clTable).new(self, t, clRecord)

	end
	
	return self._tables[t]
end


---
--@function [parent=#sfdlib.SFD] getFileUtils
--@param #sfdlib.SFD self
function SFD:getFileUtils()
	return self._fileUtils
end


return SFD