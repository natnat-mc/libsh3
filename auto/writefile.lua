return function(data, filename)
	local file, err=io.open(filename, 'w+')
	if not file then
		error(err, 2)
	end
	file:write(data)
	file:close()
end
