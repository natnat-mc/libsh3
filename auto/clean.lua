local files=require 'files'

-- make clean
os.execute('cd \"'..files.getfile('root')..'\" && make mrproper')
-- remove Makefile
os.remove(files.getfile('Makefile'))
