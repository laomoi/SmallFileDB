
local TestScene = class("TestScene", function()
    return display.newScene("TestScene")
end)


	
	
function TestScene:ctor()
  
    local mysfd = require("sfdvo.MySFD").new() -- sfdvo.MySFD#sfdvo.MySFD
   
    local record1 = mysfd:getDictItem():getOneById(12011)
    local ar = mysfd:getDictItem():getListByTypeCanBuy(1, 1)
   	local ar2 = mysfd:getDictItem():query("type >= 2 and type<=3 and can_buy=1");
 
end


return TestScene
