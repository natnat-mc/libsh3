-- writefile
-- writes a file given its content and its filename
-- throws the errors it encounters
-- transparent call, returns everything that was passed to it

return function(filename, data, ...)
	local file, err=io.open(filename, 'w+')
	if not file then
		error(err, 2)
	end
	file:write(data)
	file:close()
	return filename, data, ...
end
