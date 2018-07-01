-- doc
-- generates Markdown documentation

local util=require 'util'
local constants=require 'constants'

local asmnamereg="^(%S+)"

local function getfilename(instruction)
	local path=constants.get('autodocdir', 'string')..'/'
	local name=instruction.name
	local ext=constants.get('docext', 'string')
	return path..name..ext
end

local function gendoc(instruction)
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
	if category=='branch' then
		doc=doc..'  \nBe careful, this instruction cannot be executed in a delay slot'
	end
	
	if #instruction.doc~=0 then
		doc=doc.."\n\n"
		doc=doc.."# Misc\n"
		for i, line in ipairs(instruction.doc) do
			doc=doc..line.."  \n"
		end
		doc=doc:sub(1, -2)
	end
	
	return doc
end

return function(instruction)
	local doc=gendoc(instruction)
	local filename=getfilename(instruction)
	return doc, filename
end
