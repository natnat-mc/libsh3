-- decoder implementation generator
-- reads the instruction data and generates a C decoder accordingly

local fn=require 'fn'
local instruction=require 'instruction'
local util=require 'util'

local individualdeps={'instruction_*'}
local globaldeps={'decode_*'}
local typedefs={'word_t', 'instruction_fn_t'}
local hexdigits={'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}

local function getcodeandmask(inst)
	local code=util.itohex(util.bintoi(inst.code:gsub('%l', '0')), 4)
	local mask=util.itohex(util.bintoi(inst.code:gsub('0', '1'):gsub('%l', '0')), 4)
	return code, mask
end

local function convertlist(list)
	local code={}
	for mask, instructions in pairs(list) do
		table.insert(code, "switch(word&0x"..mask:sub(2, 4)..") {")
		for i, inst in ipairs(instructions) do
			table.insert(code, "\tcase 0x"..inst.code:sub(2, 4)..":")
			table.insert(code, "\t\t// "..inst.name)
			if inst.priv then
				table.insert(code, "\t\tif(!priv) return -1;")
			end
			if inst.nodelay then
				table.insert(code, "\t\tif(delay) return -2;")
			end
			table.insert(code, "\t\t*out="..inst.fn..";")
			table.insert(code, "\t\treturn 0;")
		end
		table.insert(code, "}")
	end
	table.insert(code, "return -1;")
	return code
end

local function getdata(inst)
	local data={}
	data.code, data.mask=getcodeandmask(inst)
	data.fn=inst:getfunctionname()
	data.priv=not inst:isuserlegal()
	data.nodelay=not inst:isdelaylegal()
	data.name=inst.name
	return data
end

local function createfn(list, prefix)
	local name="decode_"..prefix
	
	local str="int "..name.."(word_t word, int priv, int delay, instruction_fn_t *out) {\n"
	local code=convertlist(list)
	for i, line in ipairs(code) do
		str=str.."\t"..line.."\n"
	end
	str=str.."}\n"
	
	local fnobj=fn:new(name, true)
	fnobj.code=str
	fnobj.typedeps=typedefs
	fnobj.functiondeps=individualdeps
	fnobj:add()
	
	return name
end

local function getalldata(list)
	local ret={}
	for i, inst in ipairs(list) do
		table.insert(ret, getdata(inst))
	end
	return ret
end

local function generatesubs()
	local fnbyprefix={}
	local all=getalldata(instruction.list)
	for i, data in ipairs(all) do
		local prefix=data.code:sub(1, 1)
		if not fnbyprefix[prefix] then
			fnbyprefix[prefix]={}
		end
		local mask=data.mask
		if not fnbyprefix[prefix][mask] then
			fnbyprefix[prefix][mask]={}
		end
		table.insert(fnbyprefix[prefix][mask], data)
	end
	local decoders={}
	for i, prefix in ipairs(hexdigits) do
		local list=fnbyprefix[prefix] or {}
		local decoder=createfn(list, prefix)
		table.insert(decoders, decoder)
	end
	return decoders
end

local function generate()
	local subs=generatesubs()
	local code="int decode(word_t word, int priv, int delay, instruction_fn_t *out) {\n"
	code=code.."\tstatic int (*subs[16]) (word_t, int, int, instruction_fn_t*)={\n\t\t"
	code=code..table.concat(subs, ',\n\t\t')
	code=code.."\n\t};\n"
	code=code.."\t*out=NULL;\n"
	code=code.."\treturn subs[(word>>12)&0xf](word, priv, delay, out);\n"
	code=code.."}\n"
	
	local fnobj=fn:new('decode', true)
	fnobj.code=code
	fnobj.typedeps=typedefs
	fnobj.functiondeps=globaldeps
	fnobj:add()
	
	return fnobj
end

return generate
