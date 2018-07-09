-- dependency resolver
-- resolves dependencies for targets

local files=require 'files'
local dependency=require 'dependency'
local util=require 'util'
local fn=require 'fn'
local typedef=require 'typedef'

local data=files.ini '../deps.ini'

local function dep(t, v, k)
	local name=k:match("%.(.*)$")
	if v~='type' and v~='function' then
		return false, "Value of keys must be either type or function"
	end
	if not name:match("^[%l%u_%*][%l%u%d_%*]*$") then
		return false, "Name must be a valid C identifier"
	end
	return true
end

local fmt={}
fmt.lib=dep
fmt.assembler=dep
fmt.disassembler=dep
files.ini.validate(data, fmt)

local function getdeps(target)
	local typelist, fnlist={}, {}
	
	local tab=data[target]
	if not tab then
		error("Unknown target: "..target, 2)
	end
	for name, kind in pairs(tab) do
		if kind=='type' then
			table.insert(typelist, typedef:getbyname(name))
		else
			table.insert(fnlist, fn:getbyname(name))
		end
	end
	
	return dependency.resolve(util.merge(typelist), util.merge(fnlist))
end

return getdeps
