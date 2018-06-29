local constants=require 'constants'
local util=require 'util'

local makefile={}
function makefile.clean()
	local rule='clean:\n'
	rule=rule..'\trm -f '..constants.get('autocodedir', 'string')..'/*\n'
	return rule
end

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
		end
	end
	return rules, constants.get('makefile', 'string')
end
