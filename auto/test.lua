local function rangeit(max, pos)
	if pos<max then
		return pos+1
	else
		return nil
	end
end

function range(min, max)
	return rangeit, max, min-1
end

local function ipairsit(tab, pos)
	pos=pos+1
	local val=tab[pos]
	if val then
		return pos, val
	else
		return nil
	end
end

function ipairs(tab)
	return ipairsit, tab, 0
end

local tab={"aezé", 51465, "shj"}

for i, v in ipairs(tab) do
	print(i, v)
end
