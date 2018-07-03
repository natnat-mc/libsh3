local constants=require 'constants'
local util=require 'util'
local config=require 'config'
local files=require 'files'

local instructions={}

-- parse all instructions
do
	print "Parsing instructions"
	local parse=require 'parse'
	for k, name in ipairs(constants.get('instfiles', 'table.string')) do
		local file=files.getfile('inst', name..constants.get('instext', 'string'))
		table.insert(instructions, parse(file))
	end
end

-- select target instructions
do
	print "Selecting instructions for model"
	local segregate=require 'segregate'
	instructions=segregate(util.merge(instructions))
end

-- generate all implementations
if config.get('lib.generate') then
	print "Generating implementations"
	local imp=require 'imp'
	for k, instruction in pairs(instructions) do
		imp(instruction)
	end
end

-- generate decoder
if config.get('lib.generate') then
	print "Generating decoder"
	local decoder=require 'decoder'
	decoder(instructions)
end

-- generate documentation
if config.get('doc.generate') then
	print "Generating documentation"
	local doc=require 'doc'
	for k, instruction in ipairs(instructions) do
		doc(instruction)
	end
end

-- generate Makefile
do
	print "Generating Makefile"
	local makefile=require 'makefile'
	makefile()
end
