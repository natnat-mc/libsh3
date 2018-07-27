local config=require 'config'
local util=require 'util'
local instruction=require 'instruction'
local registers=require 'models'[config 'general.model'].registers

local function genld(reg, number, mem, type)
	local code='0100mmmm'..util.itobin(number, 4)
	if type=='C' then
		code=code..(mem and '0111' or '1110')
	else
		code=code..(mem and '0110' or '1010')
	end
	local name='LD'..type..(mem and 'M' or '')..'_'..reg
	local abstract=(mem and '(Rm)' or 'Rm')..' -> '..reg..(name and ', Rm+4 -> Rm' or '')
	local asm='LD'..type..(mem and '.L @Rm+' or ' Rm')..','..reg
	local doc='Loads '..reg..' from '..(mem and 'the memory address pointed by' or 'the general register')..' Rm'
	
	local inst=instruction:new(name)
	inst.type='m'
	if type=='C' then
		table.insert(inst.attributes, 'priv')
	end
	inst.category='sysctl'
	inst.code=code
	inst.abstract=abstract
	inst.asm=asm
	inst.doc={doc}
	
	if mem then
		table.insert(inst.imp, reg.."=read_long(sh3, R[m]);")
		table.insert(inst.imp, "R[m]+=4;")
	else
		table.insert(inst.imp, reg.."=R[m];")
	end
	table.insert(inst.imp, "PC+=2;")
	
	inst:add()
end

local function genst(reg, number, mem, type)
	local code=(mem and '0100' or '0000')..'nnnn'..util.itobin(number, 4)
	if type=='C' then
		code=code..(mem and '0011' or '0010')
	else
		code=code..(mem and '0010' or '1010')
	end
	local name='ST'..type..(mem and 'M' or '')..'_'..reg
	local abstract=(mem and 'Rn-4 -> Rn, ' or '')..reg..' -> '..(mem and '(Rn)' or 'Rn')
	local asm='ST'..type..(mem and '.L ' or ' ')..reg..','..(mem and '@-Rn' or 'Rn')
	local doc='Stores '..reg..' into '..(mem and 'the memory address pointed by' or 'the general register')..' Rn'
	
	local inst=instruction:new(name)
	inst.type='n'
	if type=='C' then
		table.insert(inst.attributes, 'priv')
	end
	inst.category='sysctl'
	inst.code=code
	inst.abstract=abstract
	inst.asm=asm
	inst.doc={doc}
	
	if mem then
		table.insert(inst.imp, 'R[n]-=4;')
		table.insert(inst.imp, 'write_long(sh3, R[n], '..reg..');')
	else
		table.insert(inst.imp, 'R[n]='..reg..';')
	end
	table.insert(inst.imp, 'PC+=2;')
	
	inst:add()
end

local function doreg(reg, val)
	local sysreg, ctlreg="^system,(%x)$", "^control,(%x)$"
	
	-- find register number and type
	local code, type=val:match(sysreg), 'S'
	if not code then
		code, type=val:match(ctlreg), 'C'
	end
	
	if code then
		-- register has a code attached to it
		code=util.hextoi(code)
		
		-- generate register load from register
		genld(reg, code, false, type)
		-- generate register load from RAM
		genld(reg, code, true, type)
		
		-- generate register store to register
		genst(reg, code, false, type)
		-- generate register store to RAM
		genst(reg, code, true, type)
	end
end

local function doall()
	for reg, val in pairs(registers) do
		if val then
			doreg(reg:upper(), val)
		end
	end
end

return doall
