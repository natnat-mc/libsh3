local util=require 'util'

local inifile={}

inifile.commentregex="^%s*;(.*)$"
inifile.emptyregex="^%s*$"
inifile.sectionregex="^%s*%[(.+)%]%s*$"
inifile.settingregex="^%s*(%w+)%s*=%s*([%w%p]+)%s*$"
inifile.stringregex="^%s*(%w+)%s*=%s*\"([^\"]*)\"%s*$"
inifile.varregex="%%(%w+)%.(%w+)%%"

function inifile.read(filename)
	local iterator=io.lines(filename)
	local sections={}
	local section, name
	local lineno=0
	
	for line in iterator do
		lineno=lineno+1
		
		local comment=line:match(inifile.commentregex)
		local sec=line:match(inifile.sectionregex)
		local key, value=line:match(inifile.settingregex)
		local keystr, valuestr=line:match(inifile.stringregex)
		
		if sec then
			if section then
				sections[name]=section
			end
			section={}
			name=sec
		elseif keystr then
			if not section then
				error("Attempt to write without a section at line "..lineno, 2)
			end
			local ok
			ok, valuestr=pcall(inifile.readstrvalue, valuestr, sections)
			if ok then
				section[keystr]=valuestr
			else
				error("Error while reading line "..lineno..":\n"..valuestr, 2)
			end
		elseif key then
			if not section then
				error("Attempt to write without a section at line "..lineno, 2)
			end
			section[key]=inifile.readvalue(value)
		elseif not (comment or line:match(inifile.emptyregex)) then
			error("Unrecognized option at line "..lineno, 2)
		end
	end
	
	if section then
		sections[name]=section
	end
	
	return sections
end

function inifile.readvalue(val)
	if val=='true' then
		return true
	elseif val=='false' then
		return false
	else
		return tonumber(val)
	end
end

function inifile.readstrvalue(val, sections)
	return val:gsub(inifile.varregex, function(section, name)
		if not sections[section] then
			error("No such section "..section)
		end
		local value=sections[section][name]
		if value==nil then
			error("No such setting "..name.." in section "..section)
		end
		return tostring(value)
	end)
end

function inifile.validate(ini, data, exclusive)
	for key in pairs(ini) do
		if exclusive and not data[key] then
			error("Found illegal section "..key, 2)
		end
	end
	for key in pairs(data) do
		if not ini[key] then
			error("Missing section "..key, 2)
		end
	end
	
	for name, section in pairs(ini) do
		local valid=data[name] or {}
		for key, value in pairs(section) do
			local validator=valid[key]
			if exclusive and not validator then
				error("Found illegal key "..key.." in section "..name, 2)
			end
			local vtype=type(validator)
			local dtype=type(value)
			if vtype=='string' and dtype~=validator then
				error("Key "..key.." from section "..name.." is not of type "..validator, 2)
			elseif vtype=='function' then
				local valid, msg=validator(dtype, value, name)
				if not valid then
					error("Key "..key.." from section "..name.." is not valid: "..msg, 2)
				end
			end
		end
		for key in pairs(valid) do
			if section[key]==nil then
				error("Missing key "..key.." in section "..name, 2)
			end
		end
	end
end

setmetatable(inifile, {
	['__call']=function(self, ...) return inifile.read(...) end
})

return inifile
