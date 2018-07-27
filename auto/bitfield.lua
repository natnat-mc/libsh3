local function bitfield(fields, size, transform)
	transform=transform or function(a) return a end
	
	-- reverse the names and the positions
	local ordered={}
	for name, pos in pairs(fields) do
		if type(pos)=='number' then
			ordered[pos+1]=transform(name)
		elseif type(pos)=='string' then
			local min, max=pos:match('(%d+)-(%d+)')
			if not min then
				error("The position of the field "..name.." is invalid", 2)
			end
			min, max=tonumber(min), tonumber(max)
			for i=min, max do
				ordered[i+1]=transform(name)
			end
		elseif pos~=false then
			error("The position of the field "..name.." is invalid", 2)
		end
	end
	
	-- now, group them together
	local grouped={}
	local len, current=0
	for i=1, size do
		local name=ordered[i]
		if name~=current then
			table.insert(grouped, {current, len})
			len=0
			current=name
		end
		len=len+1
	end
	table.insert(grouped, {current, len})
	if grouped[1][2]==0 then
		table.remove(grouped, 1)
	end
	
	-- build the bitfield
	local code={}
	local delimno=0
	for i, field in ipairs(grouped) do
		local name, len=field[1], field[2]
		if not name then
			name, delimno="__delimiter"..delimno, delimno+1
		end
		table.insert(code, 1, "unsigned "..name..":"..len..";")
	end
	
	return code
end

return bitfield
