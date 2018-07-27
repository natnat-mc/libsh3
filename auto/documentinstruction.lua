-- doc
-- generates Markdown documentation

local instruction=require 'instruction'
local util=require 'util'

local docs={}

local asmnamereg="^(%S+)"

local function gendoc(instruction)
	if docs[instruction.name] then
		return docs[instruction.name]
	end
	
	
	local name=instruction.name:lower():gsub("[a-z]", string.upper, 1)
	local asm=instruction.asm:gsub(asmnamereg, string.lower)
	local abstract=instruction.abstract
	local code=instruction.code
	local category=instruction.category
	
	local doc={}
	local function d(a)
		table.insert(doc, a)
	end
	
	d("# "..name.."\n")
	d("Asm: `"..asm.."`  \n")
	d("Abstract: "..abstract.."  \n")
	d("Category: "..category.."  \n")
	d("Code: `"..code.."`")
	if not instruction:isdelaylegal() then
		d('  \nBe careful, this instruction cannot be executed in a delay slot')
	end
	if not instruction:isuserlegal() then
		d('  \nBe careful, this instruction is a privileged instruction and cannot be executed in user mode')
	end
	if util.contains(instruction.attributes, 'TODO') then
		d('  \nThis instruction is still work in progress and is pretty much guaranteed to crash')
	end
	
	if #instruction.doc~=0 then
		d("\n\n")
		d("# Misc\n")
		for i, line in ipairs(instruction.doc) do
			d(line.."  \n")
		end
	end
	
	if instruction:hasimplementation() then
		d("\n\n")
		d("# Implementation\n")
		d("```c\n")
		for i, line in ipairs(instruction.imp) do
			d(line..'\n')
		end
		d("```")
	end
	
	docs[instruction.name]=table.concat(doc)
	
	return doc
end

setmetatable(docs, {
	['__call']=function(self, ...)
		local objs={}
		for i, inst in ipairs(instruction.list) do
			table.insert(objs, gendoc(inst))
		end
		return objs
	end
})

return docs
