-----
-- SFDTable
-- @module sfdlib.SFDTable

local SFDTable = class("SFDTable")

---
-- @field  [parent=#sfdlib.SFDTable] sfdlib.SFD#sfdlib.SFD _sfd 


---
-- @field [parent=#sfdlib.SFDTable] #string _name

---
-- @field [parent=#sfdlib.SFDTable] #string _clRecord


---
-- @field [parent=#sfdlib.SFDTable] #table _indexes


---
-- @field [parent=#sfdlib.SFDTable] #table _meta


---
-- @field [parent=#sfdlib.SFDTable] #table _positions


---
-- @field [parent=#sfdlib.SFDTable] sfdlib.SFDFileStream#sfdlib.SFDFileStream _bodyStream


---
--@function [parent=#sfdlib.SFDTable] ctor
--@param #sfdlib.SFDTable self
--@param SFD#SFD sfd
--@param #string tableName
--@param #string clRecord
function SFDTable:ctor(sfd, tableName, clRecord)
	self._sfd = sfd
	self._name = tableName
	self._clRecord = clRecord

	
	self._indexes = {}  --all indexes data
	self._meta = {}     -- meta data
	self._positions = {} --position info
	self._bodyStream = nil

	local cjson = require("cjson")

	--read meta
	local metaFile = sfd:getFileUtils():getFile(self._name ..  ".meta")
	if metaFile == nil then 
		error(self._name .. " has no meta file ")
		return
	end

	self._meta = cjson.decode(sfd:getFileUtils():getFileString(metaFile))
	if self._meta == nil then 
		error(self._name + " meta file incorrect " )
	end
	
	--read in indexes?
	local indexFile = sfd:getFileUtils():getFile(self._name ..  ".index");
	if indexFile == nil then
		error(self._name .. " has no index file " )
	end
	
	self._indexes = cjson.decode(sfd:getFileUtils():getFileString(indexFile))
	if self._indexes== nil or  #(self._indexes) == 0  then
		error(self._name .. " index file incorrect " )
	end	
	
	--read positions for datas
	local positionFile = sfd:getFileUtils():getFile(self._name ..  ".pos")
	if positionFile == nil then 
		error(self._name .. " has no position file ")
	end
	
	--binary file
	local positionFileStream = require("sfdlib.SFDFileStream").new(positionFile)
	local size = io.filesize(positionFile)
	local count = math.floor(size / 4)
	for i=1,count do
		--read int
		local val = positionFileStream:readInt()
		table.insert(self._positions, val)
	end
	
	
	
	--open body data prepare reading
	local bodyFile= sfd:getFileUtils():getFile(self._name ..  ".body")
	if bodyFile == nil then
		error(self._name .. " has no body file " )
	end
	self._bodyStream = require("sfdlib.SFDFileStream").new(bodyFile)

end


---
--@function [parent=#sfdlib.SFDTable] getDataPositionListByIndex
--@param #sfdlib.SFDTable self
--@param #int index
--@param #table values
function SFDTable:getDataPositionListByIndex(index, values)
	local indexData  = self._indexes[index] 
	if indexData == nil then
		error(self._name .. " has no index " .. index)
		return nil
	end
	
	local i
	local indexListData = indexData['_data']
	local data = indexListData
	

	for i=1,#values do
		--important, lua table : "100" is differ from 100 as table keys
		local strKey = tostring(values[i])
		--echo("searching " .. strKey)

		data = data[ strKey ]
		if data == nil then
			return {}
		end
	end
	return data
end 


---
--@function [parent=#sfdlib.SFDTable] getDataByPosition
--@param #sfdlib.SFDTable self
--@param #int posIndex
function SFDTable:getDataByPosition(posIndex)
	--since the posIndex is readed from the .index file ,and starts from 0 not 1, so we have to +1 for lua
	posIndex = 1 + posIndex
	local pos = self._positions[posIndex]
	

	self._bodyStream:setPos(pos)

	local types = self._meta['types']
	local rnames = self._meta['rnames']
	local data = require(self._clRecord).new()
	local i

	for i=1,#types do
		local rname = rnames[i]
		if types[i] == "int" then 
			-- read int
			local val = self._bodyStream:readInt()
			data[rname] = val
		elseif 	types[i] == "string" then 
			--read short
			local l = self._bodyStream:readShort()
			
			data[rname] = self._bodyStream:readUTFBytes(l)
		end 
		
	end

	return data
end
		

---
--@function [parent=#sfdlib.SFDTable] getOneByIndex
--@param #sfdlib.SFDTable self
--@param #int index	
--@param #table values	
function SFDTable:getOneByIndex(index, values)
	local list = self:getDataPositionListByIndex(index, values)

	if  list ~= nil and #list> 0 then 
		return self:getDataByPosition(list[1])
	else 
		return nil
	end
end

---
--@function [parent=#sfdlib.SFDTable] getListByIndex
--@param #sfdlib.SFDTable self
--@param #int index	
--@param #table values	
function SFDTable:getListByIndex(index, values) 
	local list = self:getDataPositionListByIndex(index, values)
	local listData = {} 
	for i=1,#list do
		table.insert(listData, self:getDataByPosition(list[i]))
	end
	
	return listData
end 
		
		
---
--@function [parent=#sfdlib.SFDTable] query
--@param #sfdlib.SFDTable self
--@param #string sql	
--@return #table 	
function SFDTable:query(sql) 
	local conditions = string.split(sql, "and")
	
	--fuck lua regex....
	
	local reg = "(%w+)%s*([>=<]+)%s*(.*)"
	--(>=|<=|=|>|<|<>)%s*(%d+|'.*?')
	local columnCount = 0
	local rh = {}
	local i
	for i=1,#conditions do
		local column, cond, value = string.match(conditions[i], reg)
		if column == nil then
			error(conditions[i] .. " incorrect sql ")
			return nil
		end
		if rh[column] == nil then
			rh[column] = {}
			columnCount = columnCount + 1
		end
		table.insert(rh[column],{cond, value})
	end
	
	--dump(rh)	
	
	--which index it will use
	local findedIndex = -1
	for i=1,#self._indexes do
		local raOrigin = self._indexes[i]['origin']
		if columnCount == #raOrigin then
		
			for r=1,#raOrigin do
				if rh[raOrigin[r]] == nil then
					break
				end
			end
			
			--fuck find the index
			findedIndex = i
			break			
		end
	end
	
		
	if findedIndex == -1 then
		error("correstponding index not found for " .. sql)
		return nil
	end		
	local indexData = self._indexes[findedIndex]; 
	local indexListData = indexData['_data'];
	local origin = indexData['origin'];
	local type = indexData['type'];
	local result = {}
	self:searchCondResult(result, indexListData, 1, #origin, origin, rh, type);
	local listData = {}

	for k,v in pairs(result) do
	    table.insert( listData, self:getDataByPosition(k) )
	end
	
		
	return listData
end 
		

---
--@function [parent=#sfdlib.SFDTable] setArrayInHash
--@param #sfdlib.SFDTable self
--@param #table ar	
--@param #table hs	
function SFDTable:setArrayInHash(ar, hs)

	for key, var in pairs(ar) do
		hs[key] = true
	end
end

---
--@function [parent=#sfdlib.SFDTable] searchCondResult
--@param #sfdlib.SFDTable self
--@param #table result	
--@param #table sourceData	
--@param #int depth	
--@param #int maxDepth	
--@param #table origin	
--@param #table rh	
--@param #table type	
function SFDTable:searchCondResult(result, sourceData, depth, maxDepth, origin, rh, type)	
	if maxDepth == depth then
		--leaf
		self:setArrayInHash(sourceData, result)
		return 
	end		
	local conds = rh[origin[depth]]
	local columnType = type[depth]
	
	for k,v in pairs(sourceData) do
		--fits conds
		local isFit = true;
		
		for c=1,#conds do
			
			local raCond = conds[c] --[cond, value]
			local cond = raCond[1]
			local value = raCond[2]					
			if columnType == "int" then
			
				local intK = math.floor(k)						
--				if (value.substr(0, 1) == "'"){
--					throw new Error("column:" + origin[depth] + " should have int param not : " + value);
--					return null;
--				}
				local intValue = math.floor(value)
				if cond == "<>" then
					if intK == intValue then
						isFit = false
						break
					end
				elseif cond == "=" then
					if intK ~= intValue then
						isFit = false
						break
					end
				elseif cond == ">=" then
					if intK < intValue then
						isFit = false
						break
					end
				elseif cond == "<=" then
					if intK > intValue then
						isFit = false
						break
					end
				elseif cond == "<" then
					if intK >= intValue then
						isFit = false
						break
					end
				elseif cond == ">" then
					if intK <= intValue then
						isFit = false
						break
					end
				else 
					error("column:" .. origin[depth] .. " should not have operator: " .. cond)
					return
				end
			elseif columnType == "string" then
				--remove '' from value
--				if (value.substr(0, 1) != "'" || value.substr(value.length-2, 1) != "'"){
--					throw new Error("column:" + origin[depth] + " should have string param not : " + value);
--					return ;
--				}
				value = string.sub(2, #value-1);
				if cond == "<>" then
					if k == value then
						isFit = false
						break
					end
				elseif cond == "=" then
					if k ~= value then
						isFit = false
						break
					end
				else 
					error("column:" .. origin[depth] .. " should not have operator: " .. cond)
					return
				end
			end
		end
		
		if isFit then
			self:searchCondResult(result, sourceData[k], depth+1, maxDepth,origin, rh, type);
		end
		
	end
end
		
		
			
---
--@function [parent=#sfdlib.SFDTable] close
--@param #sfdlib.SFDTable self
function SFDTable:close()
	if self._bodyStream ~= nil then 
		self._bodyStream:close()
		self._bodyStream = nil
	end
	
	self._sfd = null;
end

return SFDTable


