-- file list
-- reads files.ini and handles filename requests from other modules

local inifile=require 'inifile'

local data=inifile '../files.ini'

-- BEGIN argument check functions
local function contains(...)
	local any={...}
	return (function(t, v, n)
		if t~='string' then
			return false, n.." must be a string"
		end
		local good=false
		for i, pattern in ipairs(any) do
			good=good or v:match(pattern)
		end
		if not good then
			return false, n.." must contain at least one of "..table.concat(any, ', ')
		end
		return true
	end)
end
local function nameortrue(t, v, n)
	if v==true or t=='string' then
		return true
	end
	return false, "such fields must contain a name or true to indicate that the content is identical to the name"
end
--END argument check functions

-- BEGIN file format check
local fmt={}

-- input and output directories
fmt.directories={}
fmt.directories.root='string'
fmt.directories.instructions='string'
fmt.directories.documentation='string'
fmt.directories.functions='string'
fmt.directories.typedefs='string'
fmt.directories.output='string'

-- file names
fmt.filenames={}
fmt.filenames.instructions=contains('%%name%%')
fmt.filenames.documentation=contains('%%name%%')
fmt.filenames.functions=contains('%%name%%')
fmt.filenames.typedefs=contains('%%name%%')

-- categories
fmt.instructions=nameortrue
fmt.functions=nameortrue
fmt.typedefs=nameortrue

inifile.validate(data, fmt)
-- END file format check

local files={}
files.data=data

local function getfile(key, value, dir, pattern)
	local name=key
	if type(value)=='string' then
		name=value:gsub('%%key%%', key)
	end
	name=dir..'/'..pattern:gsub('%%name%%', name)
	return name
end

function files.list(category)
	local list={}
	local directory=data.directories[category] or data.directories[category..'s']
	local pattern=data.filenames[category] or data.filenames[category..'s']
	local object=data[category] or data[category..'s']
	if not (directory and pattern) then
		error('Unknown category: '..category, 2)
	elseif not object then
		error('Attempting to read into a write category', 2)
	end
	for key, value in pairs(object) do
		table.insert(list, getfile(key, value, directory, pattern))
	end
	return list
end

function files.listwithname(category)
	local list={}
	local directory=data.directories[category] or data.directories[category..'s']
	local pattern=data.filenames[category] or data.filenames[category..'s']
	local object=data[category] or data[category..'s']
	if not (directory and pattern) then
		error('Unknown category: '..category, 2)
	elseif not object then
		error('Attempting to read into a write category', 2)
	end
	for key, value in pairs(object) do
		local obj={}
		obj.file=getfile(key, value, directory, pattern)
		obj.name=value==true and key or value:gsub('%%name%%', key)
		table.insert(list, obj)
	end
	return list
end

function files.getfilename(category, name)
	local directory=data.directories[category] or data.directories[category..'s']
	local object=data[category] or data[category..'s']
	if object then
		error('Attempting to write into a read category', 2)
	elseif not directory then
		error('Unknown category: '..category, 2)
	end
	return directory..'/'..name
end

files.write=require 'writefile'

files.ini=inifile

return files
