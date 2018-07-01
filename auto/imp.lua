-- implementation converter
-- takes an instruction and generates the C code of its implementation

local constants=require 'constants'
local util=require 'util'

-- arguments for type
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

-- returns prototype and defines
local function getfuncdef(instruction)
	local def=''
	for i, v in ipairs(paramsfortype[instruction.type]) do
		def=def.."#define "..v.." ((longword_t) instruction.fmt_"..instruction.type..'.'..v..')\n'
	end
	def=def.."void instruction_"..instruction.name.."(sh3_t *sh3, instruction_t instruction) {"
	return def
end

-- returns C code for the implementation
local function getimp(instruction)
	local imp="#include \""..util.getrelpath(constants.get('autocodedir', 'string'), constants.get('internalincludedir', 'string')).."/instructionHeader.h\"\n\n"
	imp=imp..getfuncdef(instruction)..'\n'
	for i, v in pairs(instruction.imp) do
		imp=imp..'\t'..v..'\n'
	end
	imp=imp..'}\n'
	
	local filename=constants.get('autocodedir', 'string')..'/instruction_'..instruction.name..'.c'
	
	return imp, filename
end

return getimp
