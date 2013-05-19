-----
-- SFDFileStream, operate on bytes
-- @module sfdlib.SFDFileStream

local SFDFileStream = class("SFDFileStream")

---
-- @field  [parent=#sfdlib.SFDFileStream] #string _fullPath 


---
-- @field  [parent=#sfdlib.SFDFileStream] io#file _stream 



---
--@function [parent=#sfdlib.SFDFileStream] ctor
--@param #sfdlib.SFDFileStream self
--@param #string fullPath
function SFDFileStream:ctor(fullPath)
	self._fullPath = fullPath
	self._stream = io.open(fullPath, "rb")
end


---
--@function [parent=#sfdlib.SFDFileStream] setPos
--@param #sfdlib.SFDFileStream self
--@param #int n
function SFDFileStream:setPos(n)
	self._stream:seek("set", n)
end 

---
--@function [parent=#sfdlib.SFDFileStream] readInt
--@param #sfdlib.SFDFileStream self
--@return #int
function SFDFileStream:readInt() 
	local substr = self._stream:read(4)

	local val = self.bytes_to_int(substr, "big")
	return val
end

---
--@function [parent=#sfdlib.SFDFileStream] readShort
--@param  #sfdlib.SFDFileStream self
--@return #int
function SFDFileStream:readShort() 
	local substr = self._stream:read(2)

	local val = self.bytes_to_int(substr, "big")
	return val
end

---
--@function [parent=#sfdlib.SFDFileStream] readUTFBytes
--@param  #sfdlib.SFDFileStream self
--@return #string
function SFDFileStream:readUTFBytes(len) 
	local substr = self._stream:read(len)

	return substr
end


---
--@function [parent=#sfdlib.SFDFileStream] bytes_to_int
--@param #string str
--@param #string endian "big" or "small"
--@return #int
function SFDFileStream.bytes_to_int(str,endian,signed) -- use length of string to determine 8,16,32,64 bits
    local t = {str:byte(1,-1)}
    if endian=="big" then --reverse bytes
        local tt={}
        for k=1,#t do
            tt[#t-k+1]=t[k]
        end
        t=tt
    end
    local n=0
    for k=1,#t do
        n=n+t[k]*2^((k-1)*8)
    end
    if signed then
        n = (n > 2^(#t-1) -1) and (n - 2^#t) or n -- if last bit set, negative.
    end
    return n
end

---
--@function [parent=#sfdlib.SFDFileStream] close
--@param #sfdlib.SFDFileStream self
function SFDFileStream:close()
	if self._stream ~= nil then 
		io.close(self._stream)
	end
end


return SFDFileStream