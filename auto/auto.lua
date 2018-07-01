local constants=require 'constants'
local util=require 'util'
local parse=require 'parse'
local segregate=require 'segregate'
local imp=require 'imp'
local doc=require 'doc'
local makefile=require 'makefile'
local decoder=require 'decoder'
local writefile=require 'writefile'

-- parse all instructions
print "Reading instructions"
local objects={}
for k, v in ipairs(constants.get('instfiles', 'table.string')) do
	local file=constants.get('instdir', 'string')..'/'..v..constants.get('instext', 'string')
	table.insert(objects, parse(file))
end

-- merge all instruction lists and retain only supported instructions
objects=util.merge(objects)
objects=segregate(objects)

-- write all implementation files
print "Generating implementations"
for k, v in ipairs(objects) do
	writefile(imp(v))
end

-- write all documentation files
print "Generating documentation"
for k, v in ipairs(objects) do
	writefile(doc(v))
end

-- write decoder
print "Generating decoder"
writefile(decoder(objects))

-- write Makefile
print "Generating Makefile"
writefile(makefile())
