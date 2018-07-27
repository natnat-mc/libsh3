local models=require 'models'
local config=require 'config'
local typedef=require 'typedef'

local model=models[config 'general.model']

local function proc()
	local code={}
	
	table.insert(code, "typedef struct proc_t {")
		
		table.insert(code, "\t// registers")
		table.insert(code, "\tstruct {")
			table.insert(code, "\t\tlongword_t R[16];")
			if model.general.banks then
				table.insert(code, "\t\tlongword_t RB[8];")
			end
			for reg, present in pairs(model.registers) do
				if present then
					table.insert(code, "\t\tlongword_t "..reg:upper()..";")
				else
					table.insert(code, "\t\t// register "..reg:upper().." has been removed explicitly in this model")
				end
			end
		table.insert(code, "\t} registers;")
		
		table.insert(code, "\t// flags (stored separately for faster access)")
		table.insert(code, "\tstruct {")
			for flag, present in pairs(model.flags) do
				if present then
					table.insert(code, "\t\tunsigned int "..flag:upper()..";")
				else
					table.insert(code, "\t\t// flag "..flag:upper().." has been removed explicitly in this model")
				end
			end
		table.insert(code, "\t} flags;")
		
		table.insert(code, "\t// the instruction pipeline")
		table.insert(code, "\tstruct {")
			table.insert(code, "\t\t// words fetched from RAM")
			table.insert(code, "\t\tword_t inst0, inst1;")
			table.insert(code, "\t\t// delayed PC")
			table.insert(code, "\t\tlongword_t delayed;")
			table.insert(code, "\t\t// decoded instruction")
			table.insert(code, "\t\tinstruction_f_t inst;")
			table.insert(code, "\t\t// interrupt block count")
			table.insert(code, "\t\tint blocked;")
		table.insert(code, "\t} pipeline;")
	
	table.insert(code, "} proc_t;")
	
	local type=typedef:new('proc_t', false)
	type.code=table.concat(code, "\n")
	type.opaque=true
	type.type='struct'
	type.typedeps={'longword_t', 'word_t', 'instruction_f_t'}
	type:add()
end

return proc
