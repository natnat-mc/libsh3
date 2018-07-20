local deps=require 'deps'
local files=require 'files'
local config=require 'config'

local function generateheader(name, functions, types, includes, defines)
	local code=''
	
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
	
	-- add typedefs
	for i, typedef in ipairs(types or {}) do
		code=code.."// "..typedef.name.."\n"
		code=code..typedef:generatecode().."\n\n"
	end
	
	-- add prototypes
	for i, fn in ipairs(functions or {}) do
		code=code.."// "..fn.name.."\n"
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
