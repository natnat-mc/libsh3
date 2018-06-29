local util=require 'util'
local constants=require 'constants'
local makefile=require 'makefile'
local writefile=require 'writefile'

-- create Makefile
writefile(makefile())
-- make clean
os.execute('cd \"'..constants.get('rootdir', 'string')..'\" && make clean')
-- remove Makefile
os.remove(constants.get('makefile', 'string'))
