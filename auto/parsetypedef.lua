-- typedef parser
-- reads a typedef file and converts it to a lua representation

local typedef=require 'typedef'

local internalreg="INTERNAL%((.+)%)"
local dependsreg="DEPENDS%(([^)]+)%)"

local function parse(filename, name)
	local it=io.lines(filename)
	local code=''
	local internal=false
	local deps={}
	for line in it do
		local dep=line:match(dependsreg)
		if dep then
			table.insert(deps, dep)
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
	type:add()
end

return parse
