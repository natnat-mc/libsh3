local files=require 'files'
local util=require 'util'

local models={}

-- BEGIN internal functions
local function stringorbool(bool)
	return function(t, v, n)
		if t=='string' then
			return true
		elseif t=='boolean' and v==bool then
			return true
		end
		return false, n..' must be a string or the boolean '..tostring(bool)
	end
end
local function typeorbool(bool)
	return function(t, v, n)
		local ctlpattern="^control,(%x)$"
		local syspattern="^system,(%x)$"
		if v=='system' or v=='control' then
			return true
		elseif v:match(ctlpattern) or v:match(syspattern) then
			return true
		elseif t=='boolean' and v==bool then
			return true
		end
		return false, n..' must be "system", "control" or the boolean '..tostring(bool)
	end
end
local function numberorrange(t, v, n)
	if t=='number' and v>=0 and v<32 then
		return true
	elseif v:match('%d+-%d+') then
		return true
	elseif v==false then
		return true
	end
	return false, n..' must be a bit number or a range'
end
-- END internal functions

-- BEGIN file validator
local function validate(ini)
	local fmt={}
	
	-- [general]
	fmt.general={}
	fmt.general.name='string'
	fmt.general.parent=stringorbool(false)
	fmt.general.fpu='boolean'
	fmt.general.mmu='boolean'
	fmt.general.banks='boolean'
	
	-- [registers]
	fmt.registers=typeorbool(false)
	
	-- [flags]
	fmt.flags=numberorrange
	
	-- [defaults]
	fmt.defaults='string'
	
	files.ini.validate(ini, fmt)
end
-- END file validator

-- BEGIN inheritance manager
local function inherit(ini)
	if ini.general.parent==false then
		return
	end
	if not models[ini.general.parent] then
		error("Model "..ini.general.parent.." not found", 2)
	end
	
	local parent=models[ini.general.parent]
	inherit(parent)
	
	for secname, sec in pairs(parent) do
		if not ini[secname] then
			ini[secname]={}
		end
		local section=ini[secname]
		for k, v in pairs(sec) do
			if section[k]==nil then
				section[k]=v
			end
		end
	end
end
-- END inheritance manager

-- read all files
for i, v in ipairs(files.list('models')) do
	local ini=files.ini(v)
	if not ini.general then
		error("General section is missing", 2)
	end
	if type(ini.general.name)~='string' then
		error("Name must be a string", 2)
	end
	models[ini.general.name]=ini
end

-- inherit everything
for name, ini in pairs(models) do
	inherit(ini)
end

-- validate everything
for name, ini in pairs(models) do
	local ok, err=pcall(validate, ini)
	if not ok then
		error("In model "..name..":\n"..err)
	end
end

return models
