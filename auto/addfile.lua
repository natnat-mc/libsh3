local writefile=require 'writefile'

local addfile={}
addfile.categories={}

function addfile:add(code, filename, category)
	if category then
		if not addfile.categories[category] then
			addfile.categories[category]={}
		end
		table.insert(addfile.categories[category], filename)
	end
	writefile(code, filename)
	return filename
end

setmetatable(addfile, {
	['__call']=addfile.add
})

function addfile:getcategory(name)
	name=name or self
	return addfile.categories[name] or {}
end

return addfile
