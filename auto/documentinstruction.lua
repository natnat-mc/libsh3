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
	
	local doc="# "..name.."\n"
	doc=doc.."Asm: `"..asm.."`  \n"
	doc=doc.."Abstract: "..abstract.."  \n"
	doc=doc.."Category: "..category.."  \n"
	doc=doc.."Code: `"..code.."`"
	if not instruction:isdelaylegal() then
		doc=doc..'  \nBe careful, this instruction cannot be executed in a delay slot'
	end
	if not instruction:isuserlegal() then
		doc=doc..'  \nBe careful, this instruction is a privileged instruction and cannot be executed in user mode'
	end
	if util.contains(instruction.attributes, 'TODO') then
		doc=doc..'  \nThis instruction is still work in progress and is pretty much guaranteed to crash'
	end
	
	if #instruction.doc~=0 then
		doc=doc.."\n\n"
		doc=doc.."# Misc\n"
		for i, line in ipairs(instruction.doc) do
			doc=doc..line.."  \n"
		end
		doc=doc:sub(1, -2)
	end
	
	if instruction:hasimplementation() then
		doc=doc.."\n\n"
		doc=doc.."# Implementation\n"
		doc=doc.."```c\n"
		for i, line in ipairs(instruction.imp) do
			doc=doc..line..'\n'
		end
		doc=doc.."```"
	end
	
	docs[instruction.name]=doc
	
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
