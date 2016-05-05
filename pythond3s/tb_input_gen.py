import random
from BitVector import *



# for i in range (500):
# 	print ("logic [63:0] tb_input_test_%d = 64'h%s;"%(i, BitVector(intVal=random.randint(2**63, 2** 64 - 1 ), size = 64).get_hex_string_from_bitvector() ))


print 
print

for i in range(500):
	print ("@(negedge tb_clk);")
	print ("tb_input_block = tb_input_test_%d;"%i)
	print 