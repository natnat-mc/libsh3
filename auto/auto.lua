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

-- list all dependencies for all targets
if genlib or genasm or gendsm then
	print 'Listing all dependencies for targets'
	local deps=require 'deps'
	local function printdeps(target)
		local types, functions=deps(target)
		print('Required types for target '..target..': ('..#types..')')
		for i, t in ipairs(types) do
			print('-> '..t.name, '('..t.exportedname..')')
		end
		print('Required functions for target '..target..': ('..#functions..')')
		for i, f in ipairs(functions) do
			print('-> '..f.name, '('..f.exportedname..')')
		end
	end
	if genlib then
		printdeps('lib')
	end
	if genasm then
		printdeps('assembler')
	end
	if gendsm then
		printdeps('disassembler')
	end
end

-- generate library code
if genlib then
	print 'Generating internal library code'
	local deps=require 'deps'
	local types, functions=deps('lib')
	local header, source='', ''
	local includes={'stdint.h', 'stdlib.h', 'stdio.h'}
	
	header=header.."#ifndef __LIB"..config 'general.progname':upper()..'_H\n'
	header=header.."#define __LIB"..config 'general.progname':upper()..'_H\n'
	for i, include in ipairs(includes) do
		header=header.."#include <"..include..'>\n'
	end
	source=source.."#include \"internallib.h\"\n\n"
	for i, typedef in ipairs(types) do
		header=header..typedef:generatecode()..'\n'
	end
	for i, fn in ipairs(functions) do
		header=header..'// '..fn.name..'\n'
		header=header..fn:getprototype()..'\n\n'
		source=source..fn:generatecode()..'\n'
	end
	header=header.."#endif //__LIB"..config 'general.progname':upper()..'_H\n'
	files.write(files.getfilename('output', 'internallib.h'), header)
	files.write(files.getfilename('output', 'internallib.c'), source)
	
	print 'Generating exported library header'
	header=''
	header=header.."#ifndef __LIB"..config 'general.progname':upper()..'_H\n'
	header=header.."#define __LIB"..config 'general.progname':upper()..'_H\n'
	for i, include in ipairs(includes) do
		header=header.."#include <"..include..'>\n'
	end
	header=header.."// BEGIN exported types\n"
	for i, typedef in ipairs(types) do
		if not typedef.internal then
			header=header..typedef:generateexportedcode()..'\n'
		end
	end
	header=header.."// END exported types\n\n"
	header=header.."// BEGIN exported functions\n"
	for i, fn in ipairs(functions) do
		if not fn.internal then
			header=header..fn:getprototype()..'\n'
		end
	end
	header=header.."// END exported functions\n\n"
	header=header.."#endif //__LIB"..config 'general.progname':upper()..'_H\n'
	files.write(files.getfilename('output', 'lib.h'), header)
end
