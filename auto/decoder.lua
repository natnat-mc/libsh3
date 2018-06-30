-- decoder
-- returns the code responsible for decoding instructions

local util=require 'util'
local constants=require 'constants'

-- bitmask generators
local function getbitmask(instruction)
	local code=instruction.code:sub(5)
	local bitmask='0x'..util.itohex(util.bintoi(code:gsub('(%d)', '1'):gsub('(%l)', '0')))
	local bittest='0x'..util.itohex(util.bintoi(code:gsub('(%l)', '0')))
	return bitmask, bittest
end

-- function name getter
local function getfunction(instruction)
	return "instruction_"..instruction.name
end

-- main detector
local function detect(tab, instructions, branching)
	-- sort instructions by bitmask
	local masks={}
	for i, instruction in ipairs(instructions) do
		local bitmask, bittest=getbitmask(instruction)
		if not masks[bitmask] then
			masks[bitmask]={}
		end
		table.insert(masks[bitmask], {bittest, getfunction(instruction)})
	end
	
	-- generate detectors for all bitmasks
	for mask, instructions in pairs(masks) do
		table.insert(tab, "// check for all instructions with mask "..mask)
		table.insert(tab, "switch(inst&"..mask..") {")
		for k, v in ipairs(instructions) do
			local test, func=v[1], v[2]
			table.insert(tab, "\tcase "..test..":")
			if branching then
				table.insert(tab, "\t\tif(inDelay) return ESLOT;")
			end
			table.insert(tab, "\t\tret("..func..");")
			table.insert(tab, "\t\tbreak;")
		end
		table.insert(tab, "}")
	end
end

-- detector generators
local function detectsingle(tab, instruction)
	table.insert(tab, "// the only instruction is "..instruction.name)
	local bitmask, bittest=getbitmask(instruction)
	if bitmask~='0x0' then
		-- the code can be invalid
		table.insert(tab, "if(!MASK_EQ(inst, "..bittest..", "..bitmask..")) return EGENERAL;")
	end
	if instruction.category=='branch' then
		table.insert(tab, "if(inDelay) return ESLOT;")
	end
	table.insert(tab, "ret("..getfunction(instruction)..");")
end
local function detectseveral(tab, instructions)
	-- segregate branch instructions
	local branching, nonbranching={}, {}
	for i, instruction in ipairs(instructions) do
		table.insert(instruction.category=='branch' and branching or nonbranching, instruction)
	end
	
	if #branching==0 then
		detect(tab, instructions, false)
	elseif #nonbranching==0 then
		detect(tab, instructions, true)
	else
		detect(tab, branching, true)
		detect(tab, nonbranching, false)
	end
	table.insert(tab, "return EGENERAL;")
end

-- static code
local static=[=[
// typedefs
typedef int(*instruction_f)(sh3_t*, instruction_t);
typedef int(*decoder_f)(word_t, int, instruction_f*);
// faster function calls
#define instruction ((instruction_t) inst)
// valid return
#define ret(inst) do {*ptr=(inst); return 0;} while(0)
// for fast decoding
static decoder_f byHigh[16];
// calls special decoders
int decode(word_t inst, int inDelay, instruction_f* ptr) {
	return byHigh[(inst>>12)&0xf](inst, inDelay, ptr);
}
]=]

-- prototypes
local prototypes=''
for i=0, 15 do
	prototypes=prototypes.."static int decode"..i.."(word_t inst, int inDelay, instruction_f* ptr);\n"
end

-- init
local init="void initDecoder() {\n"
for i=0, 15 do
	init=init.."\tbyHigh["..i.."]=decode"..i..";\n"
end
init=init..'}\n'

-- includes
local includes=''
local includetable={
	'common.h',
	'decoder.h',
	'instruction.h',
	'macro.h',
	'typedef.h',
	'sh3.h'
}
for i, v in ipairs(includetable) do
	includes=includes.."#include \""..util.getrelpath(constants.get('autocodedir', 'string'), constants.get('internalincludedir', 'string')).."/"..v.."\"\n"
end

-- decoders
local decoders={}
local categories={}
local function gendecoders(instructions)
	-- sort instructions into 16 categories
	for i, instruction in ipairs(instructions) do
		local high=util.bintoi(instruction.code:sub(1, 4))
		if not categories[high] then
			categories[high]={}
		end
		table.insert(categories[high], instruction)
	end
	
	-- generate decoders for each categories
	for i=0, 15 do
		local category=categories[i]
		if not category then
			-- nothing to do, the rest will handle it
		elseif #category==1 then
			-- only one instruction
			decoders[i]={}
			detectsingle(decoders[i], category[1])
		else
			-- several instructions
			decoders[i]={}
			detectseveral(decoders[i], category)
		end
	end
end
local function getdecoders()
	local code=''
	for i=0, 15 do
		code=code.."int decode"..i.."(word_t inst, int inDelay, instruction_f* ptr) {\n"
		local decoder=decoders[i]
		if not decoder then
			decoder={
				"return EGENERAL;"
			}
		end
		for k, v in ipairs(decoder) do
			code=code..'\t'..v..'\n'
		end
		code=code..'}\n'
	end
	return code
end

-- final builder
return function(instructions)
	gendecoders(instructions)
	local code=includes..'\n'
	code=code..prototypes..'\n'
	code=code..static..'\n'
	code=code..init..'\n'
	code=code..getdecoders()
	local filename=constants.get('autocodedir', 'string')..'/decoder.c'
	return code, filename
end
