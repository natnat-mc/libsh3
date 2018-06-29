-- util
-- a collection of useful functions

local util={}

function util.contains(table, value)
	for i, v in ipairs(table) do
		if v==value then
			return true, i
		end
	end
	return false
end

function util.dump(obj, name, sep)
	name=name or 'obj'
	sep=sep or ''
	if type(obj)=='table' then
		print(sep..name..'\t'..'table')
		for k, v in pairs(obj) do
			util.dump(v, name..'.'..k, sep..'\t')
		end
	else
		print(sep..name..'\t'..type(obj)..'\t'..tostring(obj))
	end
end

function util.merge(...)
	local args, tab={...}, {}
	if #args==1 then
		return util.merge(table.unpack(args[1]))
	end
	for i, c in ipairs(args) do
		if type(c)~='table' then
			error('cannot merge a '..type(c), 2)
		end
		for k, v in ipairs(c) do
			table.insert(tab, v)
		end
	end
	return tab
end

function util.hash(str, max)
	if type(str)~='string' then
		str=type(str)..'/'..tostring(str)
	end
	local val=7
	for i=1, #str do
		val=val*31+str:byte(i)
	end
	return type(max)=='number' and val%max or val
end

util.uids={
	['name']={},
	['val']={}
}

function util.getuid(str)
	local val=util.uids.name[str]
	if val then
		return val
	end
	local name, i=str, 0
	val=util.hash(name, 65536)
	while util.uids.val[val] do
		str=val..'/'..tostring(name)..'/'..tostring(i)
		i=i+1
		val=util.hash(str, 65535)
	end
	util.uids.val[val]=name
	util.uids.name[name]=val
	return val
end

function util.splitpath(path)
	local split={}
	for part in path:gmatch("[^/]+") do
		if part=='.' or part=='' then
			-- nothing
		elseif part=='..' then
			table.remove(split)
		else
			table.insert(split, part)
		end
	end
	return split
end

function util.getrelpath(orig, dest)
	-- it will be easier to work with tables
	orig=util.splitpath(orig)
	dest=util.splitpath(dest)
	
	-- remove the common first part
	local parto, partd
	while parto==partd do
		parto=table.remove(orig, 1)
		partd=table.remove(dest, 1)
	end
	
	-- add dotdots
	local path=string.rep('../', #orig+(parto and 1 or 0))
	
	-- add the remaining parts
	if partd then
		path=path..partd..'/'
	end
	for i, v in ipairs(dest) do
		path=path..v..'/'
	end
	
	-- remove the leading slash
	return path:sub(1, -2)
end

function util.checktype(val, t)
	-- sanitize t
	if t==nil then
		t='any'
	elseif type(t)~='string' then
		error('t must be a string', 2)
	end
	
	-- primitive types
	if t=='number' or t=='string' or t=='table' or t=='function' or t=='boolean' or t=='thread' then
		if type(val)==t then
			return val
		else
			error('value is not of type '..t)
		end
	
	-- string
	elseif t=='upper' or t=='lower' then
		if type(val)==string then
			return string[t](val)
		else
			error('value is not a string')
		end
	
	-- number
	elseif t=='int' then
		if type(val)~='number' then
			error('value is not a number')
		end
		local ival=math.floor(val)
		if ival~=val then
			error('value is a decimal number')
		end
		return ival
	
	-- any
	elseif t=='any' then
		return val
	
	-- typed table
	elseif t:sub(1, 6)=='table.' then
		t=t:sub(7)
		if type(val)~='table' then
			error('value is not a table')
		end
		local tab={}
		for i, v in ipairs(val) do
			tab[i]=util.checktype(v, t)
		end
		return tab
	
	-- error
	else
		error('unknown value for argument t', 2)
	end
end

return util