local util=require 'util'

local constants={}

-- directories
constants.rootpath=''
constants.autopath='/auto'
constants.includepath='/include'
constants.internalincludepath='/include/internal'
constants.codepath='/src'
constants.autocodepath='/src/auto'
constants.instpath='/instructions'
constants.docpath='/doc'
constants.autodocpath='/doc/auto'
constants.objpath='/obj'

-- file extensions
constants.instext='.inst'
constants.docext='.md'

-- files
constants.Makefilepath='/Makefile'
constants.instfiles={
	'add',
	'and',
	'bcond',
	'branch',
	'clr',
	'cmp',
	'div',
	'mul',
	'test',
	'ext',
	'jmp',
	'ldc'
}

-- getter
function constants.get(name, t)
	return t and util.checktype(constants[name], t) or constants[name]
end

return constants
