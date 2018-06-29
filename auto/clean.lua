local util=require 'util'
local constants=require 'constants'
local makefile=require 'makefile'
local writefile=require 'writefile'

writefile(makefile())
os.execute('cd \"'..constants.get('rootdir', 'string')..'\" && make clean')
os.remove(constants.get('makefile', 'string'))
