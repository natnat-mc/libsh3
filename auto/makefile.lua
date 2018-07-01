local constants=require 'constants'
local util=require 'util'

local makefile={}

-- find out what the main file is
local main
if constants.get('lib', 'boolean') then
	main=constants.get('progname', 'string')..'.a'
else
	main=constants.get('progname', 'string')
end

-- make clean
function makefile.clean()
	local rule='clean:\n'
	rule=rule..'\trm -f '..constants.get('autocodedir', 'string')..'/*\n'
	rule=rule..'\trm -f '..constants.get('autodocdir', 'string')..'/*\n'
	return rule
end

-- make mrproper
function makefile.mrproper()
	local rule='mrproper: clean\n'
	rule=rule..'\trm -f '..main..'\n'
	return rule
end

-- make all
makefile.all={
	'all: '..main..'\n'
}

-- .PHONY
makefile.phony={
	'.PHONY: clean mrproper all'
}

-- build the makefile
return function()
	local rules=''
	for k, v in pairs(makefile) do
		if type(v)=='function' then
			rules=rules..v()..'\n'
		elseif type(v)=='string' then
			rules=rules..v..'\n'
		elseif type(v)=='table' then
			for i, rule in ipairs(v) do
				rules=rules..rule..'\n'
			end
			rules=rules..'\n'
		end
	end
	return rules, constants.get('makefile', 'string')
end
