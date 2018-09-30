local deps=require 'deps'
local files=require 'files'
local config=require 'config'
local models=require 'models'

local function generateheader(name, functions, types, includes, defines, showopaque)
	local code={}
	local usestatic=not config 'static.exportinternal'
	
	local function i(a)
		return table.insert(code, a)
	end
	
	-- generate ifndef header
	local ifndef='__'..name:gsub('%l', string.upper):gsub('%.', '_')
	i("#ifndef "..ifndef.."\n")
	i("#define "..ifndef.."\n\n")
	
	-- include required libs
	for _, include in ipairs(includes or {}) do
		i("#include <"..include..">\n")
	end
	i("\n")
	
	-- define everything that should be defined
	for _, define in ipairs(defines or {}) do
		if type(define)=='string' then
			i("#define "..define.."\n")
		else
			i("#define "..(define.name or define[1]).."\t"..(define.value or define[2]).."\n")
		end
	end
	i("\n\n")
	
	-- add trivial typedefs
	for _, typedef in ipairs(types or {}) do
		if typedef.type=='trivial' then
			i("// declaration of type "..typedef.name.."\n")
			i(typedef:generatecode().."\n\n")
		end
	end
	
	-- add struct and union opaque types
	for _, typedef in ipairs(types or {}) do
		if typedef.type=='struct' or typedef.type=='union' then
			if typedef.opaque then
				i("// definition of opaque type "..typedef.name.."\n")
			else
				i("// initial declaration of "..typedef.type.." type "..typedef.name.."\n")
			end
			i("typedef "..typedef.type.." "..typedef.exportedname.." "..typedef.exportedname..";\n\n")
		end
	end
	
	-- add method types
	for _, typedef in ipairs(types or {}) do
		if typedef.type=='function' then
			i("// declaration of function type "..typedef.name.."\n")
			i(typedef:generatecode().."\n\n")
		end
	end
	
	-- add the real struct and union type
	for _, typedef in ipairs(types or {}) do
		if (typedef.type=='struct' or typedef.type=='union') and (showopaque or not typedef.opaque) then
			i("// final declaration of "..typedef.type.." type "..typedef.name.."\n")
			i(typedef:generatecode().."\n\n")
		end
	end
	i("\n")
	
	-- add prototypes
	for _, fn in ipairs(functions or {}) do
		i("// "..fn.name.."\n")
		if fn.internal and usestatic then
			i("static ")
		end
		i(fn:getprototype().."\n\n")
	end
	
	-- add endif footer
	i("#endif //"..ifndef.."\n")
	
	return table.concat(code)
end

local function generatesource(header, functions, includes)
	local code={}
	
	local function i(a)
		return table.insert(code, a)
	end
	
	-- add includes
	i("#include \""..header.."\"\n\n")
	for _, include in ipairs(includes or {}) do
		i("#include <"..include..">\n")
	end
	
	i("\n")
	
	-- add functions
	for _, fn in ipairs(functions or {}) do
		i("// "..fn.name.."\n")
		i(fn:generatecode().."\n\n")
	end
	
	return table.concat(code)
end

local function generate(target)
	local types, functions=deps(target)
	
	-- generate statistics
	local count={}
	count.exportedtypes, count.exportedfunctions=0, 0
	count.internaltypes, count.internalfunctions=0, 0
	count.opaquetypes=0
	count.unions, count.structs, count.fntypes, count.trivialtypes=0, 0, 0, 0
	
	for k, t in ipairs(types) do
		if t.internal then
			count.internaltypes=count.internaltypes+1
		else
			count.exportedtypes=count.exportedtypes+1
		end
		if t.opaque then
			count.opaquetypes=count.opaquetypes+1
		end
		if t.type=='struct' then
			count.structs=count.structs+1
		elseif t.type=='function' then
			count.fntypes=count.fntypes+1
		elseif t.type=='union' then
			count.unions=count.unions+1
		elseif t.type=='trivial' then
			count.trivialtypes=count.trivialtypes+1
		end
	end
	
	for k, f in ipairs(functions) do
		if f.internal then
			count.internalfunctions=count.internalfunctions+1
		else
			count.exportedfunctions=count.exportedfunctions+1
		end
	end
	
	print("Generating code for target "..target)
	
	
	print("-> "..#types.." types")
	print("   -> "..count.exportedtypes.." exported")
	print("   -> "..count.internaltypes.." internal")
	print("   -> "..count.opaquetypes.." opaque")
	print("   -> "..count.structs.." structs")
	print("   -> "..count.unions.." unions")
	print("   -> "..count.fntypes.." function pointers")
	print("   -> "..count.trivialtypes.." trivial types")
	
	print("-> "..#functions.." functions")
	print("   -> "..count.exportedfunctions.." exported")
	print("   -> "..count.internalfunctions.." internal")
	
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
		
		-- get the model to define constants accordingly
		local curr=models[config 'general.model']
		set('banks', curr.general.banks)
		set('mmu', curr.general.mmu)
		set('fpu', curr.general.fpu)
		
		-- define general constants
		set('progname', config 'general.progname')
		set('model', config 'general.model')
		set('version', config 'general.version')
		set('debug', config 'general.debug')
		
		-- define model macro
		set(config 'general.model')
		
		-- set model inheritance
		while curr do
			set('least_'..curr.general.name)
			curr=models[curr.general.parent]
		end
		
		-- generate library code
		local internalheader=generateheader(name, functions, types, includes, defines, true)
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
