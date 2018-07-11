-- fn parser
-- parses functions and generates fn objects accordingly

local fn=require 'fn'

local idreg="[%l%u_%*][%l%u%d_%*]*"
local depreg="DEPENDS%s*%(("..idreg..")%s*,%s*([tf])%)"
local intreg="INTERNAL%s*%((.+)%)"
local inclreg="^#include%s+(%b<>)"
local increg="^#include%s+(%b\"\")"
local defreg="^#define%s+("..idreg..")%s+(.*)$"
local voidreg="^%s*$"

local function parse(file, name)
	local deps={}
	deps.f, deps.t={}, {}
	local code=''
	local includes={}
	local defines={}
	
	for line in io.lines(file) do
		local inc, incl=line:match(increg), line:match(increg)
		local dep, dept=line:match(depreg)
		local def, defv=line:match(defreg)
		if inc then
			table.insert(includes, inc:sub(2, -2))
		elseif incl then
			table.insert(includes, incl)
		elseif dep then
			table.insert(deps[dept], dep)
		elseif def then
			defines[def]=defv
		elseif not line:match(voidreg) then
			code=code..line..'\n'
		end
	end
	
	local int=code:match(intreg)
	if int then
		code=int
	end
	
	local f=fn:new(name, int)
	f.code=code
	f.includes=includes
	f.defines=defines
	f.typedeps=deps.t
	f.functiondeps=deps.f
	f:add()
	
	return f
end

return parse
