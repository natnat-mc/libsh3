local inifile=require 'inifile'
local util=require 'util'

local cfg=inifile("../config.ini")

-- BEGIN argument check functions
local function contains(...)
	local any={...}
	return (function(t, v, n)
		if t~='string' then
			return false, n.." must be a string"
		end
		local good=false
		for i, pattern in ipairs(any) do
			good=good or v:match(pattern)
		end
		if not good then
			return false, n.." must contain at least one of "..table.concat(any, ', ')
		end
		return true
	end)
end

local function oneof(...)
	local set={...}
	return (function(t, v, n)
		if not util.contains(set, v) then
			return false, n.." must be one of "..table.concat(set, ', ')
		end
		return true
	end)
end
-- END argument check functions

-- BEGIN format
local fmt={}

-- [general]
-- controls general information about the program
fmt.general={}
fmt.general.model=oneof('sh3', 'sh3dsp', 'sh4', 'sh4a')
fmt.general.mpu='string'
fmt.general.version='number'
fmt.general.progname='string'
fmt.general.debug='boolean'

-- [naming]
-- controls how the functions are named
fmt.naming={}
fmt.naming.exportfunction=contains('%%name%%', '%%mangle%%')
fmt.naming.internalfunction=contains('%%name%%', '%%mangle%%')
fmt.naming.exporttype=contains('%%name%%', '%%mangle%%')
fmt.naming.internaltype=contains('%%name%%', '%%mangle%%')

-- [shared]
-- controls the generation of the shared library
fmt.shared={}
fmt.shared.generate='boolean'
fmt.shared.name='string'

-- [static]
-- controls the generation of the static library
fmt.static={}
fmt.static.generate='boolean'
fmt.static.name='string'

-- [assembler]
-- controls the generation of the assembler
fmt.assembler={}
fmt.assembler.generate='boolean'
fmt.assembler.name='string'

-- [disassembler]
-- controls the generation of the disassembler
fmt.disassembler={}
fmt.disassembler.generate='boolean'
fmt.disassembler.name='string'

-- [doc]
-- controls the generation of the documentation
fmt.doc={}
fmt.doc.generate='boolean'

-- [compile]
-- controls the compilation process
fmt.compile={}
fmt.compile.CC='string'
fmt.compile.LD='string'
fmt.compile.CFLAGS='string'
fmt.compile.LFLAGS='string'

inifile.validate(cfg, fmt)
-- END format

local config={}
config.cfg=cfg

function config.get(section, name)
	if not name then
		section, name=section:match("^(%w+)%.(%w+)$")
	end
	if not section then
		error("Error in arguments", 2)
	end
	local sec=cfg[section]
	if not sec then
		error("No such section "..section, 2)
	end
	local val=sec[name]
	if val==nil then
		error("No such key "..name.." in section "..section, 2)
	end
	return val
end

setmetatable(config, {
	['__call']=function(self, ...) return config.get(...) end
})

return config
