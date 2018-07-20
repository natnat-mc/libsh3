-- instruction implementation generator
-- generates functions that execute the actual instruction based on the spec

local fn=require 'fn'
local instruction=require 'instruction'
local util=require 'util'

-- type to param list
local params={
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
local registers={
	'R',
	'PC', 'PR', 'SPC',
	'GBR', 'VBR', 'SSR',
	'MACH', 'MACL'
}
local flags={
	'T',
	'S', 'M', 'Q',
	'MD',
	'RB',
	'BL',
	'FD',
	'IMASK'
}
local macros={
	['SIGN_EXTEND4']={'a', "(((a)&0x8)?(0x0000000f&(a)):(0xfffffff0|(a)))"},
	['SIGN_EXTEND8']={'a', "(((a)&0x80)?(0x000000ff&(a)):(0xffffff00|(a)))"},
	['SIGN_EXTEND12']={'a', "(((a)&0x800)?(0x00000fff&(a)):(0xfffff000|(a)))"},
	['SIGN_EXTEND16']={'a', "(((a)&0x8000)?(0x0000ffff&(a)):(0xffff0000|(a)))"},
	['ZERO_EXTEND4']={'a', "((a)&0xf)"},
	['ZERO_EXTEND8']={'a', "((a)&0xff)"},
	['ZERO_EXTEND12']={'a', "((a)&0xfff)"},
	['ZERO_EXTEND16']={'a', "((a)&0xffff)"}
}
local typedefs={
	'proc_t', 'instruction_t',
	'ulongword_t', 'longword_t',
	'uword_t', 'word_t',
	'ubyte_t', 'byte_t'
}

-- lists the defines required by the instruction
local function getdefines(instruction, imp)
	for i, param in ipairs(params[instruction.type]) do
		local value='(((instruction_t) word).type_'..instruction.type..'.'..param..')'
		imp.defines[param]=value
	end
end

-- writes the emulation code
local function getcode(instruction, imp)
	local code='void '..instruction:getfunctionname()..'(proc_t *proc, word_t word) {\n'
	for i, line in ipairs(instruction.imp) do
		code=code..'\t'..line..'\n'
	end
	code=code..'}\n'
	imp.code=code
	
	local impcode=table.concat(instruction.imp, '\n')
	for i, register in ipairs(registers) do
		if impcode:match(register) then
			imp.defines[register]='proc->registers.'..register
		end
	end
	for i, flag in ipairs(flags) do
		if impcode:match(flag) then
			imp.defines[flag]='proc->flags.'..flag
		end
	end
	for macro, val in pairs(macros) do
		if impcode:match(macro) then
			mac=macro.."("..val[1]..")"
			imp.defines[mac]=val[2]
		end
	end
end

-- appends dependencies to the list
local function getdeps(instruction, imp)
	local typedeps=util.merge(typedefs, instruction.typedeps)
	for i, typedef in ipairs(typedeps) do
		table.insert(imp.typedeps, typedef)
	end
	
	for i, functiondep in ipairs(instruction.functiondeps) do
		table.insert(imp.functiondeps, functiondep)
	end
end

-- single instruction generator
local function implementinstruction(instruction)
	-- create an instruction
	local imp=fn:new(instruction:getfunctionname(), true)
	
	-- setup the necessary dependencies for it
	getdefines(instruction, imp)
	
	-- write the code
	getcode(instruction, imp)
	
	-- append dependencies
	getdeps(instruction, imp)
	
	-- finalize the 
	imp:add()
	return imp
end

-- full generator
local function implementall()
	local functions={}
	for i, inst in ipairs(instruction.list) do
		table.insert(functions, implementinstruction(inst))
	end
	return functions
end

return implementall
