-- implementation converter
-- takes an instruction and generates the C code of its implementation

local constants=require 'constants'
local util=require 'util'

local paramsfortype={
	['0']={},
	['n']={'n'},
	['m']={'m'},
	['nm']={'n', 'm'},
	['md']={'m', 'd'},
	['nd4']={'n', 'd'},
	['d']={'d'},
	['d12']={'d'},
	['nd8']={'n', 'd'},
	['i']={'i'},
	['ni']={'n', 'i'}
}
local includes={
	{'internalincludedir', 'common.h'},
	{'internalincludedir', 'sh3.h'},
	{'internalincludedir', 'macro.h'},
	{'internalincludedir', 'typedef.h'}
}
local function getincludedef()
	local def=""
	for k, v in ipairs(includes) do
		local rel=util.getrelpath(constants.get('autocodedir', 'string'), constants.get(v[1], 'string'))..'/'..v[2]
		def=def.."#include \""..rel.."\"\n"
	end
	return def
end

local function getfuncdef(instruction)
	local def="void instruction_"..instruction.name.."(sh3_t *sh3"
	local params=paramsfortype[instruction.type]
	for i, v in ipairs(params) do
		def=def..", longword_t "..v
	end
	def=def..") {"
	return def
end

local function getimp(instruction)
	local imp=getincludedef()..'\n'
	imp=imp..getfuncdef(instruction)..'\n'
	for i, v in pairs(instruction.imp) do
		imp=imp..'\t'..v..'\n'
	end
	imp=imp..'}\n'
	
	local filename=constants.get('autocodedir', 'string')..'/instruction_'..instruction.name..'.c'
	
	return imp, filename
end

return getimp
