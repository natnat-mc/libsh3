-- auto-magic code generator
-- auto-magically finds out what we need to generate, and generates it
-- yes, just like that


-- parse the INI files
print 'Reading the ini files'
local files=require 'files'
local config=require 'config'

-- see what we need to generate
print 'Checking what we need to generate'
local genshared=config 'shared.generate'
if genshared then
	print '-> The shared library'
end
local genstatic=config 'static.generate'
if genstatic then
	print '-> The static library'
end
local genlib=genshared or genstatic
if genlib then
	print '-> The processor instruction implementations'
	print '-> The decoder'
end
local gendoc=config 'doc.generate'
if gendoc then
	print '-> The documentation'
end
local genasm=config 'assembler.generate'
if genasm then
	print '-> The assembler'
end
local gendsm=config 'disassembler.generate'
if gendsm then
	print '-> The disassembler'
end

-- load all required modules
print 'Loading required modules'
require 'parseinstruction'
require 'parsetypedef'
require 'parsefunction'
if genlib then
	require 'implementinstruction'
	require 'implementdecoder'
end
if gendoc then
	require 'documentinstruction'
end
if genlib or genasm or gendsm then
	require 'deps'
	require 'generatecode'
end

-- parse the instructions
print 'Reading instructions from disk'
for i, file in ipairs(files.list 'instructions') do
	local parse=require 'parseinstruction'
	parse(file)
end

-- parse the typedefs
print 'Reading types from disk'
for i, file in ipairs(files.listwithname 'typedefs') do
	local parse=require 'parsetypedef'
	parse(file.file, file.name)
end

-- parse the functions
print 'Reading functions from disk'
for i, file in ipairs(files.listwithname 'functions') do
	local parse=require 'parsefunction'
	parse(file.file, file.name)
end

-- generate the implementations if we need to
if genlib then
	print 'Generating instruction implementations'
	local imp=require 'implementinstruction'
	imp()
end

-- generate the decoder if we need to
if genlib then
	print 'Generating instruction decoder'
	local decoder=require 'implementdecoder'
	decoder()
end

-- generate the documentation if we need to
if gendoc then
	print 'Generating instruction documentation'
	local doc=require 'documentinstruction'
	doc()
	print 'Writing documentation to disk'
	for name, text in pairs(doc) do
		local filename=files.getfilename('documentation', name)
		files.write(filename, text)
	end
end

-- generate library code
if genlib then
	print 'Generating library code'
	local generate=require 'generatecode'
	generate('lib')
end
