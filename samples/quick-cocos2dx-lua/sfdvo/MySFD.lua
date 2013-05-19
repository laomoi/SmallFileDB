-----
-- @module sfdvo.MySFD

---
-- @field  [parent=#sfdvo.MySFD] sfdlib.SFD#sfdlib.SFD super



local SFD = require("sfdlib.SFD")
local MySFD = class("MySFD", SFD)

---
--@function [parent=#sfdvo.MySFD] ctor
--@param #sfdvo.MySFD self
function MySFD:ctor()
	self.super.ctor(self)
    self:addTable("dict_item", "sfdvo.DictItem", "sfdvo.DictItemRecord")
	
end

---
--@function [parent=#sfdvo.MySFD] getDictItem
--@param #sfdvo.sfdvo self
--@return MySFD.DictItem#MySFD.DictItem
function MySFD:getDictItem()
	return self:getTable("dict_item")
end			



return MySFD