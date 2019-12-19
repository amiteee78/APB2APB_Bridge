#!/usr/bin/python3
from numpy import array, transpose
mem_rd = open("ram.hex","r");
mem_wr = open("ram_format.hex",'w+')

list = mem_rd.read().split('\n')
list.pop()

mem_array = transpose(array(list).reshape(4,256))
for i,j in enumerate(mem_array):
  #print('{0:08x}'.format(i)+' '*4+' '.join(map(str, j[::-1])))
  mem_wr.writelines('{0:08x}'.format(i)+' '*4+' '.join(map(str, j[::-1]))+'\n')

mem_rd.close()
mem_wr.close()