-----
-- @module sfdvo.DictItem

---
-- @field  [parent=#sfdvo.DictItem] sfdlib.SFDTable#sfdlib.SFDTable super



local SFDTable = require("sfdlib.SFDTable")
local DictItem = class("DictItem", SFDTable)


---
--@function [parent=#sfdvo.DictItem] ctor
--@param #sfdvo.DictItem self
--@param #string tableName
--@param #string clRecord
function DictItem:ctor(sfd, tableName, clRecord)
	self.super.ctor(self, sfd, tableName, clRecord)
end



---
--@function [parent=#sfd.DictItemRecord] getOneById
--@param #sfd.DictItem self
--@param #int id
--@return sfd.DictItemRecord#sfd.DictItemRecord
function DictItem:getOneById(id)
	return self:getOneByIndex(1, {id}) 
end



---
--@function [parent=#sfd.DictItemRecord] getListById
--@param #sfd.DictItem self
--@param #int id
--@return #table
function DictItem:getListById(id)
	return self:getListByIndex(1, {id}) 
end




---
--@function [parent=#sfd.DictItemRecord] getOneByTypeCanBuy
--@param #sfd.DictItem self
--@param #int type
--@param #int canBuy
--@return sfd.DictItemRecord#sfd.DictItemRecord
function DictItem:getOneByTypeCanBuy(type,canBuy)
	return self:getOneByIndex(2, {type,canBuy}) 
end



---
--@function [parent=#sfd.DictItemRecord] getListByTypeCanBuy
--@param #sfd.DictItem self
--@param #int type
--@param #int canBuy
--@return #table
function DictItem:getListByTypeCanBuy(type,canBuy)
	return self:getListByIndex(2, {type,canBuy}) 
end







return DictItem
