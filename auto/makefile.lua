local files=require 'files'
local config=require 'config'
local util=require 'util'

local makefile={}
local header=''
local phony={}

-- BEGIN generators
local function addheader(data)
	if type(data)=='table' then
		for k, line in ipairs(data) do
			header=header..line..'\n'
		end
	else
		header=header..data..'\n'
	end
	header=header..'\n'
end

local function genrule(name, deps, commands)
	local rule=name..':'
	if #deps~=0 then
		rule=rule..' '..table.concat(deps, ' ')
	end
	rule=rule..'\n'
	for k, command in ipairs(commands) do
		rule=rule..'\t'..command..'\n'
	end
	return rule..'\n'
end

local function genrules()
	local rules=''
	for k, rule in pairs(makefile) do
		local name, deps, commands
		if #rule==3 then
			name, deps, commands=table.unpack(rule)
		elseif #rule==2 then
			name, deps, commands=k, table.unpack(rule)
		else
			name, deps, commands=rule.name, rule.deps, rule.commands
		end
		rules=rules..genrule(name, deps, commands)..'\n'
	end
	return rules
end

local function addrule(name, fn)
	local rule={}
	rule.name=name
	rule.deps={}
	rule.commands={}
	local function adddep(dep)
		return table.insert(rule.deps, dep)
	end
	local function addcommand(cmd)
		return table.insert(rule.commands, cmd)
	end
	fn(adddep, addcommand, rule)
	makefile[name]=rule
end

local function addphony(target)
	table.insert(phony, target)
end

local function genphony()
	if #phony~=0 then
		addheader('.PHONY: '..table.concat(phony, ' '))
	end
end
-- END generators

-- BEGIN object lister
local objects={}
local categories={'imp', 'decoder'}
for i, category in ipairs(categories) do
	for k, source in ipairs(files.add.getcategory(category)) do
		local obj={}
		obj.source=source
		obj.category=category
		obj.object=files.getfile('obj', util.getfilename(source):gsub('.c$', '.o'))
		table.insert(objects, obj)
	end
end
-- END object lister

-- BEGIN basic rules

addrule('clean', function(dep, cmd)
	-- remove all object files
	for i, object in ipairs(objects) do
		cmd('rm -f '..object.object)
	end
end)

addrule('mrproper', function(dep, cmd)
	dep('clean')
	-- remove the documentation
	if config.get('doc.generate') then
		cmd('rm -f '..files.getfile('autodoc', '*'))
	end
	-- remove generated source files
	for i, object in ipairs(objects) do
		cmd('rm -f '..object.source)
	end
	-- remove binaries
	if config.get('lib.generate') then
		cmd('rm -f '..files.getfile('root', config.get('lib.name')))
	end
	if config.get('assembler.generate') then
		cmd('rm -f '..files.getfile('root', config.get('assembler.name')))
	end
	if config.get('disassembler.generate') then
		cmd('rm -f '..files.getfile('root', config.get('disassembler.name')))
	end
end)

addrule('all', function(dep, cmd)
	if config.get('lib.generate') then
		dep(config.get('lib.name'))
	end
	if config.get('assembler.generate') then
		dep(config.get('assembler.name'))
	end
	if config.get('disassembler.generate') then
		dep(config.get('disassembler.name'))
	end
end)

-- END basic rules

-- BEGIN .PHONY

addphony('all')
addphony('clean')
addphony('mrproper')

if config.get('lib.generate') then
	addphony(config.get('lib.name'))
end
if config.get('assembler.generate') then
	addphony(config.get('assembler.name'))
end
if config.get('disassembler.generate') then
	addphony(config.get('disassembler.name'))
end

-- END .PHONY

-- BEGIN Makefile function

return function()
	genphony()
	
	local code=header..'\n'
	code=code..genrules()
	
	local filename=files.getfile('Makefile')
	
	files.add(code, filename, 'Makefile')
end

-- END Makefile function
