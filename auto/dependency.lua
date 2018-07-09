-- dependency resolver
-- takes a list of functions and typedef names and returns the full dependency chain

local fn=require 'fn'
local typedef=require 'typedef'

local dependency={}

function dependency.resolve(types, functions)
	local deptypes, depfunctions={}, {}
	
	local pendingtypes, pendingfunctions={}, {}
	local checkedtypes, checkedfunctions={}, {}
	
	for i, v in ipairs(types) do
		table.insert(pendingtypes, v)
	end
	for i, v in ipairs(functions) do
		table.insert(pendingfunctions, v)
	end
	
	while #pendingfunctions~=0 do
		local current=table.remove(pendingfunctions)
		if not checkedfunctions[current.name] then
			table.insert(depfunctions, current)
			for i, fn in ipairs(current:getfunctiondependencies()) do
				table.insert(pendingfunctions, fn)
			end
			for i, t in ipairs(current:gettypedependencies()) do
				table.insert(pendingtypes, t)
			end
		end
		checkedfunctions[current.name]=true
	end
	
	while #pendingtypes~=0 do
		local current=table.remove(pendingtypes)
		if not checkedtypes[current.name] then
			table.insert(deptypes, current)
			for i, t in ipairs(current:gettypedependencies()) do
				table.insert(pendingtypes, t)
			end
		end
		checkedtypes[current.name]=true
	end
	
	return deptypes, depfunctions
end

setmetatable(dependency, {
	['__call']=function(self, ...)
		return dependency.resolve(...)
	end
})

return dependency
