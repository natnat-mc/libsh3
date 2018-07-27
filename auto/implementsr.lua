local bitfield=require 'bitfield'
local flags=require 'models'[require 'config' 'general.model'].flags
local typedef=require 'typedef'
local fn=require 'fn'

local function sr()
	local code=bitfield(flags, 32, string.upper)
	local codestr="typedef union sr_t {\n\tlongword_t word;\n\tstruct{\n\t\t"
	codestr=codestr..table.concat(code, "\n\t\t")
	codestr=codestr.."\n\t};\n} sr_t;"
	
	local type=typedef:new('sr_t', true)
	type.code=codestr
	type.type='union'
	type:add()
end

local function get()
	local code={}
	table.insert(code, "longword_t getSR(proc_t *sh3) {")
		table.insert(code, "\tsr_t sr;")
		table.insert(code, "\tsr.word=0x00000000;")
		for flag in pairs(flags) do
			local f=flag:upper()
			table.insert(code, "\tsr."..f.."=sh3->flags."..f..";")
		end
		table.insert(code, "\treturn sr.word;")
	table.insert(code, "}")
	code=table.concat(code, "\n")
	
	local f=fn:new('getSR', true)
	f.code=code
	f.typedeps={'proc_t', 'sr_t', 'longword_t'}
	f:add()
	end
	
local function set()
	local code={}
	table.insert(code, "void setSR(proc_t *sh3, longword_t val) {")
		table.insert(code, "\tsr_t sr;")
		table.insert(code, "\tsr.word=val;")
		for flag in pairs(flags) do
			local f=flag:upper()
			table.insert(code, "\tsh3->flags."..f.."=sr."..f..";")
		end
	table.insert(code, "}")
	code=table.concat(code, "\n")
	
	local f=fn:new('setSR', true)
	f.code=code
	f.typedeps={'proc_t', 'sr_t', 'longword_t'}
	f:add()
	end

local function generate()
	sr()
	get()
	set()
end

return generate
