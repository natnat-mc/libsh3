-- typedef object
-- holds typedef data

local util=require 'util'
local config=require 'config'

-- BEGIN class definition
local typedef={}
local proto={}
local meta={
	["__index"]=proto
}
-- END class definition

-- BEGIN class fields
typedef.list={}
typedef.byname={}
-- END class fields

-- constructor
function typedef:new(name, internal)
	local instance={}
	setmetatable(instance, meta)
	
	-- data seen by the generated program
	instance.name=name
	instance.internal=internal and true or false
	instance.exportedname=typedef:getexportedname(name, internal)
	
	-- data seen by the function
	instance.typedeps={}
	instance.code=''
	
	return instance
end

-- BEGIN class methods
function typedef:getexportedname(name, internal)
	local replace, pattern={}
	replace.mangle=util.getuid('TYPEDEF_'..name)
	replace.name=name
	if internal then
		pattern=config.get 'naming.internaltype'
	else
		pattern=config.get 'naming.exporttype'
	end
	return pattern:gsub("%%(%w+)%%", function(a) return replace[a] end)
end

function typedef:getbyname(name)
	if not name:match("%*") then
		return {typedef.byname[name]}
	end
	local list={}
	name=name:gsub("%*", ".*")
	for i, obj in ipairs(typedef.list) do
		print(obj.name)
		if obj.name:match(name) then
			table.insert(list, obj)
		end
	end
	return list
end
-- END class methods

-- BEGIN instance methods
function proto:add()
	if util.contains(typedef.list, self) then
		return true
	end
	table.insert(typedef.list, self)
	typedef.byname[self.name]=self
	return true
end

function proto:gettypedependencies()
	local list={}
	for i, dep in ipairs(self.typedeps) do
		table.insert(list, typedef:getbyname(dep))
	end
	return util.merge(list)
end

function proto:generatecode()
	local code=self.code
	local names={}
	
	-- rename the name of the current object
	names[self.name]=self.exportedname
	
	-- replace type names by their exported counterpart
	for i, typeobj in ipairs(self:gettypedependencies()) do
		names[typeobj.name]=typeobj.exportedname
	end
	
	-- apply the replace function
	local pattern="[%l%u_][%l%u%d_]*"
	code=code:gsub(pattern, names)
	
	return code
end

function proto:generateexportedcode()
	return self:generatecode()
	-- TODO replace the #includes with #defines and #undefs to avoid having multiple files
end
-- END instance methods

return typedef
