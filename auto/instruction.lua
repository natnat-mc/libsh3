-- instruction object
-- holds instruction information

local util=require 'util'
local config=require 'config'

-- BEGIN class definition
local instruction={}
local proto={}
local meta={
	["__index"]=proto
}
-- END class definition

-- BEGIN class fields
instruction.list={}
instruction.byname={}
instruction.bycode={}
-- END class fields

-- BEGIN misc variables
local validtypes={'0', 'n', 'm', 'nm', 'md', 'nd4', 'nmd', 'd', 'd12', 'nd8', 'i', 'ni'}
local validcategories={
	'arithmetic',
	'logic',
	'branch',
	'control',
	'sysctl'
}

local model='\"'..config.get 'general.model'..'\""'
-- END misc variables

-- constructor
function instruction:new(name)
	local elem={}
	elem.name=name
	elem.imp={}
	elem.doc={}
	elem.attributes={}
	elem.category='none'
	elem.type='none'
	setmetatable(elem, meta)
	return elem
end


-- BEGIN class methods
function instruction:getbyname(name)
	return instruction.byname[name:upper()]
end

function instruction:getbycode(code)
	local inst=instruction.bycode[code]
	if inst then
		return inst
	end
	for i, inst in ipairs(instruction.list) do
		if inst:hascode(code) then
			return inst
		end
	end
	return nil
end
-- END class methods

-- BEGIN instance methods
function proto:add()
	if util.contains(instruction.list, self) then
		return true
	end
	if self.exclusive=='any' or self.exclusive:match(model) then
		table.insert(instruction.list, self)
		instruction.byname[self.name]=self
		instruction.bycode[self.code]=self
		return true
	end
	return false
end

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
	if not util.contains(validcategories, self.category) then
		return false, "Invalid category "..self.category
	end
	if not self.exclusive then
		self.exclusive='any'
	end
	return true
end

function proto:isdelaylegal()
	if self.category=='branch' then
		return false
	end
	if util.contains(self.attributes, 'nodelay') then
		return false
	end
	return true
end
function proto:isuserlegal()
	if util.contains(self.attributes, 'priv') then
		return false
	end
	return true
end

function proto:hasimplementation()
	for i, line in ipairs(self.imp) do
		if #line and not line:match("$%s+^") then
			return true
		end
	end
	return false
end

function proto:hascode(code)
	if self.code==code then
		return true
	end
	if code:match(self.code:gsub('%l', '%d')) then
		return true
	end
	return false
end

function proto:getfunctionname()
	return 'instruction_'..self.name
end
-- END instance methods

return instruction
