local util=require 'util'

local constants={}

-- BEGIN user-supplied constantants
constants.rootdir='/home/Nathan/mnt/cifs/raspnathan2/public/workspace/casio/sh3'
constants.progname='libsh4'
constants.model='sh4'
constants.version='0.1'
constants.debug=false
constants.lib=true
-- BEGIN user-supplied constantants

-- directories
constants.includedir=constants.rootdir..'/include'
constants.internalincludedir=constants.includedir..'/internal'
constants.codedir=constants.rootdir..'/src'
constants.autocodedir=constants.codedir..'/auto'
constants.instdir=constants.rootdir..'/instructions'

-- file extensions
constants.instext='.inst'

-- files
constants.makefile=constants.rootdir..'/Makefile'
constants.instfiles={
	'add',
	'and',
	'bcond',
	'branch',
	'clr'
}

-- getter
function constants.get(name, t)
	return util.checktype(constants[name], t)
end

return constants
