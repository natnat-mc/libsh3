local deps=require 'deps'
local files=require 'files'
local config=require 'config'

local function generateheader(name, functions, types, includes, defines)
	local code=''
	local usestatic=not config 'static.exportinternal'
	
	-- generate ifndef header
	local ifndef='__'..name:gsub('%l', string.upper):gsub('%.', '_')
	code=code.."#ifndef "..ifndef.."\n"
	code=code.."#define "..ifndef.."\n\n"
	
	-- include required libs
	for i, include in ipairs(includes or {}) do
		code=code.."#include <"..include..">\n"
	end
	code=code.."\n"
	
	-- define everything that should be defined
	for i, define in ipairs(defines or {}) do
		if type(define)=='string' then
			code=code.."#define "..define.."\n"
		else
			code=code.."#define "..(define.name or define[1]).."\t"..(define.value or define[2]).."\n"
		end
	end
	code=code.."\n"
	
	-- add trivial typedefs
	for i, typedef in ipairs(types or {}) do
		if typedef.type=='trivial' then
			code=code.."// declaration of type "..typedef.name.."\n"
			code=code..typedef:generatecode().."\n\n"
		end
	end
	
	-- add struct and union opaque types
	for i, typedef in ipairs(types or {}) do
		if typedef.type=='struct' or typedef.type=='union' then
			code=code.."// initial declaration of "..typedef.type.." type "..typedef.name.."\n"
			code=code.."typedef "..typedef.type.." "..typedef.exportedname.." "..typedef.exportedname..";\n\n"
		end
	end
	
	-- add method types
	for i, typedef in ipairs(types or {}) do
		if typedef.type=='function' then
			code=code.."// declaration of function type "..typedef.name.."\n"
			code=code..typedef:generatecode().."\n\n"
		end
	end
	
	-- add the real struct and union type
	for i, typedef in ipairs(types or {}) do
		if typedef.type=='struct' or typedef.type=='union' then
			code=code.."// final declaration of "..typedef.type.." type "..typedef.name.."\n"
			code=code..typedef:generatecode().."\n\n"
		end
	end
	
	-- add prototypes
	for i, fn in ipairs(functions or {}) do
		code=code.."// "..fn.name.."\n"
		if fn.internal and usestatic then
			code=code.."static "
		end
		code=code..fn:getprototype().."\n\n"
	end
	
	-- add endif footer
	code=code.."#endif //"..ifndef.."\n"
	
	return code
end

local function generatesource(header, functions, includes)
	local code=''
	
	-- add includes
	code=code.."#include \""..header.."\"\n\n"
	for i, include in ipairs(includes or {}) do
		code=code.."#include <"..include..">\n"
	end
	
	code=code.."\n"
	
	-- add functions
	for i, fn in ipairs(functions or {}) do
		code=code.."// "..fn.name.."\n"
		code=code..fn:generatecode().."\n\n"
	end
	
	return code
end

local function generate(target)
	local types, functions=deps(target)
	
	if target=='lib' then
		local includes={'stdint.h', 'stdlib.h'}
		local name='lib'..config 'general.model'..'.h'
		local defines={}
		
		
		local function set(key, value)
			if type(value)=='string' then
				table.insert(defines, {key:upper(), '\"'..value..'\"'})
			elseif type(value)=='number' then
				table.insert(defines, {key:upper(), value})
			elseif type(value)=='boolean' and value or true then
				table.insert(defines, key:upper())
			end
		end
		
		-- define general constants
		set('progname', config 'general.progname')
		set('model', config 'general.model')
		set('mpu', config 'general.mpu')
		set('version', config 'general.version')
		set('debug', config 'general.debug')
		
		-- define model and MPU macros
		set(config 'general.model')
		set(config 'general.mpu')
		
		-- define base level macros
		local baselevel={
			['sh4a']={'sh4a', 'sh4', 'sh3', 'sh2', 'sh1'},
			['sh4']={'sh4', 'sh3', 'sh2', 'sh1'},
			['sh3']={'sh3', 'sh2', 'sh1'},
			['sh2']={'sh2', 'sh1'},
			['sh1']={'sh1'}
		}
		for i, base in ipairs(baselevel[config 'general.model'] or {}) do
			set('least_'..base)
		end
		
		-- generate library code
		local internalheader=generateheader(name, functions, types, includes, defines)
		local internalsource=generatesource('internallib.h', functions, includes)
		
		-- discriminate public types and functions
		local publictypes, publicfunctions={}, {}
		for i, t in ipairs(types) do
			if not t.internal then
				table.insert(publictypes, t)
			end
		end
		for i, f in ipairs(functions) do
			if not f.internal then
				table.insert(publicfunctions, f)
			end
		end
		
		-- generate public header
		local publicheader=generateheader(name, publicfunctions, publictypes, includes)
		
		-- write everything to disk
		files.write(files.getfilename('output', name), publicheader)
		files.write(files.getfilename('output', 'internallib.h'), internalheader)
		files.write(files.getfilename('output', 'internallib.c'), internalsource)
	end
end

return generate
