from BitVector import BitVector

with open('s-box-tables.txt') as f:
    array = []

    for line in f:                                          # for every line in file
        if len(line) > 6:                                   # if its a line with entries we care about
            array.append([int(x) for x in line.split()])    # add to giant array

s_box = []
for i in range(0, 32, 4):
    s_box.append([array[k] for k in range(i, i + 4)])       # form into usable sboxes



for chunk in range(8):
    print ("case(input_wires[%d:%d])" % (6*chunk , 6*(chunk+1) - 1 ))
    
    for i in range(64):
        i_bv = BitVector(intVal=i,size=6)
        two_bit = i_bv.permute([0, 5])                           # row index
        four_bit = i_bv[1:5]    

        row = int(two_bit)
        col = int(four_bit)

        s_box_val = s_box[chunk][row][col]

        print ("    6'b%06s: output_wires[%d:%d] = 4'd%d;"%(i_bv, chunk*4,(chunk+1)*4 - 1,  s_box_val))
    print ("endcase\n")

