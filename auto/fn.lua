-- fn object
-- holds fn data

local util=require 'util'
local config=require 'config'
local typedef=require 'typedef'

-- BEGIN class definition
local fn={}
local proto={}
local meta={
	["__index"]=proto
}
-- END class definition

-- BEGIN class fields
fn.list={}
fn.byname={}
-- END class fields

-- constructor
function fn:new(name, internal)
	local instance={}
	setmetatable(instance, meta)
	
	-- data seen by the generated program
	instance.name=name
	instance.internal=internal and true or false
	instance.exportedname=fn:getexportedname(name, internal)
	
	-- data seen by the function
	instance.functiondeps={}
	instance.typedeps={}
	instance.defines={}
	instance.includes={}
	instance.code=''
	
	return instance
end

-- BEGIN class methods
function fn:getexportedname(name, internal)
	local replace, pattern={}
	replace.mangle=util.getuid('FUNCTION_'..name)
	replace.name=name
	if internal then
		pattern=config.get 'naming.internalfunction'
	else
		pattern=config.get 'naming.exportfunction'
	end
	return pattern:gsub("%%(%w+)%%", function(a) return replace[a] end)
end

function fn:getbyname(name)
	if not name:match("%*") then
		return {fn.byname[name]}
	end
	local list={}
	name=name:gsub("%*", ".*")
	for i, obj in ipairs(fn.list) do
		if obj.name:match(name) then
			table.insert(list, obj)
		end
	end
	return list
end
-- END class methods

-- BEGIN instance methods
function proto:add()
	if util.contains(fn.list, self) then
		return true
	end
	table.insert(fn.list, self)
	fn.byname[self.name]=self
	return true
end

function proto:gettypedependencies()
	local list={}
	for i, dep in ipairs(self.typedeps) do
		table.insert(list, typedef:getbyname(dep))
	end
	return util.merge(list)
end
function proto:getfunctiondependencies()
	local list={}
	for i, dep in ipairs(self.functiondeps) do
		table.insert(list, fn:getbyname(dep))
	end
	return util.merge(list)
end

function proto:getcode(code)
	code=code or self.code
	local names={}
	
	-- rename the name of the current object
	names[self.name]=self.exportedname
	
	-- replace type names by their exported counterpart
	for i, typeobj in ipairs(self:gettypedependencies()) do
		names[typeobj.name]=typeobj.exportedname
	end
	
	-- replace function names by their exported counterparts
	for i, fnobj in ipairs(self:getfunctiondependencies()) do
		names[fnobj.name]=fnobj.exportedname
	end
	
	-- apply the replace function
	local pattern="[%l%u_][%l%u%d_]*"
	code=code:gsub(pattern, names)
	
	return code
end

function proto:generatecode()
	local code=self:getcode()
	
	-- add includes
	local header, footer='', ''
	header='// BEGIN auto-generated code for function '..self.name..'\n'
	for i, include in ipairs(self.includes) do
		if include:match('^<[^>]+>$') then
			header=header.."#include "..include.."\n"
		else
			header=header.."#include \""..include.."\"\n"
		end
	end
	header=#header and (header..'\n') or ''
	
	-- add defines
	for define, value in pairs(self.defines) do
		header=header.."#define "..define.."\t"..self:getcode(value).."\n"
		footer=footer.."\n#undef "..define
	end
	header=#header and (header..'\n') or ''
	footer=#footer and ('\n'..footer) or ''
	
	footer=footer..'\n// END auto-generated code for function '..self.name
	
	return header..code..footer..'\n'
end

function proto:getprototype()
	return self:getcode():match("([^{]+){")..';'
end
-- END instance methods

return fn
