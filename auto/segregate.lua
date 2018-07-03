-- segregate
-- retains only supported instructions for selected processor model

local util=require 'util'
local config=require 'config'

local model=config.get('general.model')

local function selected(exclusive)
	if exclusive=='any' then
		return true
	end
	return exclusive:match("\""..model.."\"") and true or false
end

return function(list)
	local instructions={}
	for i, instruction in ipairs(list) do
		if selected(instruction.exclusive) then
			table.insert(instructions, instruction)
		end
	end
	return instructions
end
