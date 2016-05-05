from BitVector import BitVector

with open('s-box-tables.txt') as f:
    array = []

    for line in f:                                          # for every line in file
        if len(line) > 6:                                   # if its a line with entries we care about
            array.append([int(x) for x in line.split()])    # add to giant array

s_box = []
for i in range(0, 32, 4):
    s_box.append([array[k] for k in range(i, i + 4)])       # form into usable sboxes


for i in range (8):
    print ("logic [0:15] intermediate_wires_%d;"%(i))

print 


print ("always_comb\nbegin")

for chunk in range(8):
    print ("case(input_wires[%d:%d])" % (6*chunk + 1, 6*(chunk+1) - 2 ))
    
    for i in range(16):
        i_bv = BitVector(intVal=i,size=4)
        # two_bit = i_bv.permute([0, 5])                           # row index
        # four_bit = i_bv[1:5]    

        # row = int(two_bit)
        # col = int(four_bit)


        s_box_val =  ''.join([BitVector(intVal=b[int(i_bv)],size=4).get_hex_string_from_bitvector() for b in [a for a in s_box[chunk]]])


        print ("    4'b%04s: intermediate_wires_%d[0:15] = 16'h%s;"%(i_bv,chunk,  s_box_val))



    print ("endcase\n")

print ("end")

for chunk in range(8):
    #print ("case({input_wires[%d],input_wires[%d]}):" % (6*chunk , 6*(chunk+1) - 1 ))
    

    print ("assign output_wires[%2d:%2d] = intermediate_wires_%d[{input_wires[%d],input_wires[%d]} +: 4];"%(chunk*4, (chunk+1)*4 - 1, chunk, 6*chunk , 6*(chunk+1) - 1 ))




    #6*chunk , 6*(chunk+1) - 1 print ("endcase\n")

