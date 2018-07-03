local util=require 'util'
local constants=require 'constants'
local config=require 'config'

local files={}

function files.getfile(filetype, name)
	local basedir=config.get('general', 'rootdir')
	local dir=constants.get(filetype..'path', 'string')
	if name then
		return basedir..dir..'/'..name
	else
		return basedir..dir
	end
end

function files.getrelpath(from, to)
	local basedir=config.get('general', 'rootdir')
	local fromdir=basedir..constants.get(from..'path', 'string')
	local todir=basedir..constants.get(to..'path', 'string')
	return util.getrelpath(fromdir, todir)
end

files.write=require 'writefile'
files.add=require 'addfile'
files.ini=require 'inifile'

return files
