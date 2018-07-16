-- instruction file parser
-- reads instruction description files

local instruction=require 'instruction'
local util=require 'util'

local commandregex="@([a-z]+)%s+(.*)%s*$"
local commentregex="//(.*)$"
local properties={"asm", "abstract", "code", "type", "category", "exclusive"}
local appendproperties={"typedeps", "functiondeps", "attribute", "doc"}

local function parse(iterator)
	local currentobj
	local lineno=0
	for line in iterator do
		local command, arg=line:match(commandregex)
		local comment=line:match(commentregex)
		comment=comment~='' and comment or nil
		lineno=lineno+1
		if currentobj then
			if command=="begin" then
				-- handle duplicate begin
				error("Unfinished object with name "..currentobj.name.." at line "..lineno)
			elseif command=="end" then
				-- make sure we're finishing the current object
				if arg~=currentobj.name then
					error("Finishing the wrong instruction")
				end
				-- validate and finish an object
				local ok, err=currentobj:validate()
				if not ok then 
					error("Error validating instruction "..(currentobj.name or '??')..":\n"..err)
				end
				currentobj:add()
				currentobj=nil
			elseif util.contains(appendproperties, command) then
				-- append to property list
				table.insert(currentobj[command], arg)
			elseif util.contains(properties, command) then
				-- set property
				currentobj[command]=arg
			elseif command and command~='' then
				error("Unknown command ".." at line "..lineno)
			else
				-- C code
				table.insert(currentobj.imp, line)
			end
		else
			if command=="begin" then
				currentobj=instruction:new(arg)
			elseif line~='' and not comment then
				error("No object to write to at line "..lineno)
			end
		end
	end
	if currentobj then
		error("Unfinished object with name "..currentobj.name)
	end
end

local function parseFile(filename)
	return parse(io.lines(filename), filename)
end

-- parse either a file or an iterator
return function(obj, name)
	if type(obj)=='function' then
		return parse(obj, name)
	elseif type(obj)=='string' then
		return parseFile(obj)
	else
		error("obj should be a filename or an iterator", 2)
	end
end
