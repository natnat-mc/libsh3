local inifile=require 'inifile'
local constants=require 'constants'
local util=require 'util'

local cfg=inifile("../config.ini")

local fmt={}

fmt.general={}
fmt.general.progname='string'
fmt.general.version='number'
fmt.general.debug='boolean'
fmt.general.rootdir='string'
fmt.general.model=function(t, v)
	if t~='string' then
		return false, "model must be a string"
	end
	local models={'sh3', 'sh3dsp', 'sh4', 'sh4a'}
	if not util.contains(models, v) then
		return false, "model must be one of "..table.concat(models, ', ')
	end
	return true
end

fmt.doc={}
fmt.doc.generate='boolean'

fmt.lib={}
fmt.lib.generate='boolean'
fmt.lib.name='string'
fmt.lib.functionname=function(t, v)
	if t~='string' then
		return false, "function name must be a string"
	end
	if not v:match("%%name%%") then
		return false, "function name must contain \'%name%\'"
	end
	return true
end

fmt.assembler={}
fmt.assembler.generate='boolean'
fmt.assembler.name='string'

fmt.disassembler={}
fmt.disassembler.generate='boolean'
fmt.disassembler.name='string'

inifile.validate(cfg, fmt)

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

return config
