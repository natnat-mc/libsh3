local files=require 'files'
local util=require 'util'
local config=require 'config'
local constants=require 'constants'

print(files.getrelpath('autocode', 'internalinclude'))
print(config.get('lib.name'))
print(files.getfile('Makefile'))
