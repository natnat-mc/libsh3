local util=require 'util'

local constants={}

-- BEGIN user-supplied constants

-- root directory, necessary for auto setup system
--constants.rootdir='/home/Nathan/mnt/cifs/raspnathan2/public/workspace/casio/sh3'
constants.rootdir='/rasp/shares/public/workspace/casio/sh3'

-- program name and version
constants.progname='libsh4'
constants.version='0.1'

-- processor model
constants.model='sh4'

-- release mode
constants.debug=false
constants.lib=true
constants.prefix='SH4_'

-- END user-supplied constants

-- BEGIN static constants

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

-- END static constants

-- getter
function constants.get(name, t)
	return util.checktype(constants[name], t)
end

return constants
