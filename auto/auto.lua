local constants=require 'constants'
local util=require 'util'
local parse=require 'parse'
local imp=require 'imp'
local makefile=require 'makefile'
local writefile=require 'writefile'

-- parse all instructions
local objects={}
for k, v in ipairs(constants.get('instfiles', 'table.string')) do
	local file=constants.get('instdir', 'string')..'/'..v..constants.get('instext', 'string')
	table.insert(objects, parse(file))
end
objects=util.merge(objects)

-- write all implementation files
for k, v in ipairs(objects) do
	writefile(imp(v))
end

-- write Makefile
writefile(makefile())
