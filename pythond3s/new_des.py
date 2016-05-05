#!/usr/bin/env/python

# Homework Header
# Homework Number: 2 (part 1)
# Name: Nico Bellante
# ECN Login: nbellant
# Due Date: 1/22/2015

import struct
import sys

from BitVector import *


################################   Initial setup  ################################

init_perm_inv = [39, 7, 47, 15, 55, 23, 63, 31, 38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29, 36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27, 34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25, 32, 0, 40, 8, 48, 16, 56, 24]
init_perm = [57, 49, 41, 33, 25, 17, 9, 1, 59, 51, 43, 35, 27, 19, 11, 3, 61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7, 56, 48, 40, 32, 24, 16, 8, 0, 58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4, 62, 54, 46, 38, 30, 22, 14, 6]

# Expansion permutation (See Section 3.3.1):
expansion_permutation = [31, 0, 1, 2, 3, 4, 3, 4, 5, 6, 7, 8, 7, 8,
                         9, 10, 11, 12, 11, 12, 13, 14, 15, 16, 15, 16, 17, 18, 19, 20, 19,
                         20, 21, 22, 23, 24, 23, 24, 25, 26, 27, 28, 27, 28, 29, 30, 31, 0]

# P-Box permutation (the last step of the Feistel function in Figure 4):
p_box_permutation = [15, 6, 19, 20, 28, 11, 27, 16, 0, 14, 22, 25, 4, 17, 30, 9,
                     1, 7, 23, 13, 31, 26, 2, 8, 18, 12, 29, 5, 21, 10, 3, 24]

# Initial permutation of the key (See Section 3.3.6):
key_permutation_1 = [56, 48, 40, 32, 24, 16, 8, 0, 57, 49, 41, 33, 25, 17, 9, 1, 58,
                     50, 42, 34, 26, 18, 10, 2, 59, 51, 43, 35, 62, 54, 46, 38, 30, 22, 14, 6, 61, 53, 45, 37,
                     29, 21, 13, 5, 60, 52, 44, 36, 28, 20, 12, 4, 27, 19, 11, 3]

# Contraction permutation of the key (See Section 3.3.7):
key_permutation_2 = [13, 16, 10, 23, 0, 4, 2, 27, 14, 5, 20, 9, 22, 18, 11, 3, 25,
                     7, 15, 6, 26, 19, 12, 1, 40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47, 43, 48, 38, 55,
                     33, 52, 45, 41, 49, 35, 28, 31]

# Each integer here is the how much left-circular shift is applied
# to each half of the 56-bit key in each round (See Section 3.3.5):
shifts_key_halvs = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]




###################################   S-boxes  ##################################


with open('s-box-tables.txt') as f:
    array = []

    for line in f:                                          # for every line in file
        if len(line) > 6:                                   # if its a line with entries we care about
            array.append([int(x) for x in line.split()])    # add to giant array

s_box = []
for i in range(0, 32, 4):
    s_box.append([array[k] for k in range(i, i + 4)])       # form into usable sboxes




################################# Generating round keys  ########################
def extract_round_key(nkey):  # round key
    round_key = []
    for i in range(16):                                     # 16 rounds
        [left, right] = nkey.divide_into_two()              # divide
        left << shifts_key_halvs[i]                         # shift
        right << shifts_key_halvs[i]                        # shift

        nkey = left + right                                 # join
        round_key.append(nkey.permute(key_permutation_2))   # add to list

    return round_key                                        # returns a list of the round keys


########################## encryption and decryption #############################
def fiesty_feistel(prevRE, round_key):

    expanded_bv = prevRE.permute(expansion_permutation)                             # expansion permutation
    expanded_bv ^= round_key                                                        # xor with round key

    new_bv = BitVector(intVal=0, size=32)                                           # create new bv to hold the 32 bits

    for i in range(8):                                                              # for 8, 6 bit chunks
        two_bit = expanded_bv.permute([6 * i, 6 * i + 5])                           # row index
        four_bit = expanded_bv[6 * i + 1:6 * i + 5]                                 # col index
        two_dec = two_bit.int_val()                                                 # grab int
        four_dec = four_bit.int_val()                                               # grab int

        new_bv[4 * i:4 * i + 4] = BitVector(intVal=s_box[i][two_dec][four_dec], size=4)     # place new 4 bits

    blah = new_bv.permute(p_box_permutation)

    return blah                                     # p box permutation


def des(encrypt_or_decrypt, bitvec, round_key):
    bitvec = bitvec.permute(init_perm)

    [LE, RE] = bitvec.divide_into_two()                                         # split

    for i in range(16):                                                         # 16 rounds
        old_RE = RE       

        if (encrypt_or_decrypt == '-e'):                                         
            RE = LE ^ fiesty_feistel(RE, round_key[i])
        else:
            RE = LE ^ fiesty_feistel(RE, round_key[15 - i])

        LE = old_RE                                                             

    finished_bv = RE + LE      

    finished_bv = finished_bv.permute(init_perm_inv)

    return finished_bv



def tripleDES(file_bv, key_list, e_or_d):
    if e_or_d == '-d':
        key_list.reverse()

    print '192bitkey(hex): ',''.join([key.get_hex_string_from_bitvector() for key in key_list])

    key_56_list = [key.permute(key_permutation_1) for key in key_list]
    round_keys = [extract_round_key(key) for key in key_56_list] 

    output_bv = BitVector(size=0)

    for i in range(int(len(file_bv)/64)):
        block = file_bv[i*64:(i+1)*64]

        out1 = des(e_or_d, block, round_keys[0])
        out2 = des(e_or_d, out1, round_keys[1])
        out3 = des(e_or_d, out2, round_keys[2])

        output_bv += out3 

    return output_bv

def seperateKeys(Sx, Sy):
    return [Sx[1:65], Sx[65:129], Sx[129:163] + Sy[134:164]]

def hexdump(src, length=16):
    FILTER = ''.join([(len(repr(chr(x))) == 3) and chr(x) or '.' for x in range(256)])
    lines = []
    for c in xrange(0, len(src), length):
        chars = src[c:c+length]
        hex = ' '.join(["%02x" % ord(x) for x in chars])
        printable = ''.join(["%s" % ((ord(x) <= 127 and FILTER[ord(x)]) or '.') for x in chars])
        lines.append("%04x  %-*s  %s\n" % (c, length*3, hex, printable))
    return ''.join(lines)


def runTripleDes():
    sxy_list = open(sys.argv[6],'r').read().split('\n')

    Sx = BitVector(hexstring=sxy_list[0].lower())
    Sy = BitVector(hexstring=sxy_list[1].lower())

    if len(Sx) != 164 or len(Sy) != 164:
        raise ValueError("Keys are not the correct size.")

    key_64_list = seperateKeys(Sx, Sy)

    if sys.argv[2] == '-t':
        file_bv = BitVector(textstring=open(sys.argv[1],'r').read())
    elif sys.argv[2] == '-h':
        file_bv = BitVector(hexstring=open(sys.argv[1],'r').read())
    else:
        raise Exception

    if sys.argv[5] == '-e' and len(file_bv)%64 != 0:
        file_bv.pad_from_right(64-(len(file_bv) % 64))

    result = tripleDES(file_bv, key_64_list, sys.argv[5])

    if sys.argv[5] == '-d':
        i = len(result) - 8
        while i > 0:
            if int(result[i::]) != 0:
                break
            i -= 8
        i += 8

        result = result[0:i]


    if sys.argv[5] == '-e':
        print("\n\nOUTPUT (ciphertext):\n\n")
    else:
        print("\n\nOUTPUT (decrypted):\n\n")

    print (hexdump(result.get_text_from_bitvector()))

    if sys.argv[4] == '-t':
        open(sys.argv[3],'w').write(result.get_text_from_bitvector())
    elif sys.argv[4] == '-h':
        open(sys.argv[3],'w').write(result.get_hex_string_from_bitvector())
    else:
        raise Exception

    if len(sys.argv) == 9:
        if sys.argv[8] == '-t':
            verilog_output = BitVector(textstring=open(sys.argv[7],'r').read())
        elif sys.argv[8] == '-h':
            verilog_output = BitVector(hexstring=open(sys.argv[7],'r').read())

        if verilog_output.get_hex_string_from_bitvector() != result.get_hex_string_from_bitvector():
            raise ValueError("Output does not match python!")


    print ("\n")


#################################### main ######################################

if __name__ == "__main__":
    generate = 0
    if len(sys.argv) == 2 and sys.argv[1] == "generate": 
        generate = 1 
        pass
    elif len(sys.argv) < 7:
        print ("usage: python new_des.py input_file -t/-h output_file -t/-h -e/-d KEY_FILE_SX_NL_SY verilog_output -t/-h")
        raise Exception

    if generate:
        i = 0
        sys.argv[1] = './inputblock_{0}.txt'.format(i)
        sys.argv.append('-t')
        sys.argv.append('./outputofdes_{0}.txt'.format(i))
        sys.argv.append('-t')
        sys.argv.append('-e')
        sys.argv.append('./test_keys.txt')
        runTripleDes()
        for i in range(1, 100):
            sys.argv[1] = './inputblock_{0}.txt'.format(i)
            sys.argv[2] = '-t'
            sys.argv[3] = './outputofdes_{0}.txt'.format(i)
            sys.argv[4] = '-t'
            sys.argv[5] = '-e'
            sys.argv[6] = './test_keys.txt'
            runTripleDes()

    else:
        runTripleDes()










