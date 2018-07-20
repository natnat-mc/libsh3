-- typedef parser
-- reads a typedef file and converts it to a lua representation

local typedef=require 'typedef'

local internalreg="INTERNAL%((.+)%)"
local dependsreg="DEPENDS%(([^)]+)%)"
local typereg="TYPE%(([^)]+)%)"

local function parse(filename, name)
	local it=io.lines(filename)
	local code=''
	local internal=false
	local deps={}
	local kind='trivial'
	for line in it do
		local dep=line:match(dependsreg)
		local t=line:match(typereg)
		if dep then
			table.insert(deps, dep)
		elseif t then
			kind=t
		else
			code=code..line..'\n'
		end
	end
	code=code:sub(1, -2)
	local internal=code:match(internalreg)
	if internal then
		code=internal
	end
	local type=typedef:new(name, internal)
	type.typedeps=deps
	type.code=code
	type.type=kind
	type:add()
end

return parse
