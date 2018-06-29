-- instruction object
-- holds instruction information

local util=require 'util'

local instruction={}
local proto={}
local meta={
	["__index"]=proto
}

function instruction:new(name)
	local elem={}
	elem.name=name
	elem.imp={}
	elem.doc={}
	setmetatable(elem, meta)
	return elem
end

local validtypes={'0', 'n', 'm', 'nm', 'md', 'nd4', 'nmd', 'd', 'd12', 'nd8', 'i', 'ni'}


function proto:validate()
	if not util.contains(validtypes, self.type) then
		return false, "Invalid type "..self.type
	end
	if type(self.name)~='string' then
		return false, "Name isn't a string"
	end
	if type(self.code)~='string' then
		return false, "Code isn't a string"
	elseif #self.code~=16 then
		return false, "Code isn't 16-character long"
	end
	if type(self.asm)~='string' then
		return false, "Asm isn't a string"
	end
	if type(self.imp)~='table' then
		return false, "Implementation isn't a table"
	end
	if type(self.doc)~='table' then
		return false, "Doc isn't a table"
	end
	return true
end

return instruction
