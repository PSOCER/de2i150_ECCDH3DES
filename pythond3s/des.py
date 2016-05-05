#!/usr/bin/env/python

# Homework Header
# Homework Number: 2 (part 1)
# Name: Nico Bellante
# ECN Login: nbellant
# Due Date: 1/22/2015

import struct
import random
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

# Now create your s-boxes as an array of arrays by reading the contents
# of the file s-box-tables.txt:

with open('s-box-tables.txt') as f:
    array = []

    for line in f:                                          # for every line in file
        if len(line) > 6:                                   # if its a line with entries we care about
            array.append([int(x) for x in line.split()])    # add to giant array

s_box = []
for i in range(0, 32, 4):
    s_box.append([array[k] for k in range(i, i + 4)])       # form into usable sboxes



#######################  Get encryption key from user  ###########################

def get_encryption_key(key_bv):  # key
    ## ask user for input
    #user_supplied_key = ""

    #while (len(user_supplied_key) != 8):  ## make sure it satisfies any constraints on the key
    #    user_supplied_key = raw_input("Please provide an 8 character key: ")

    ## next, construct a BitVector from the key

    # with open(key_file, 'r') as f:
    #     key = f.read()

    # key_bv = BitVector(textstring=key)

    #key_bv = BitVector(hexstring='557573757a15b617')
    #key_bv = BitVector(hexstring='007fffc1821569')
    #print ("64 bit key: %s"%(key_bv.get_hex_string_from_bitvector()))


    key_bv = key_bv.permute(key_permutation_1)
    #key_bv = BitVector(hexstring='007fffc1821569')

    return key_bv


################################# Generating round keys  ########################
def extract_round_key(nkey):  # round key
    print (nkey.get_hex_string_from_bitvector())
    round_key = []
    for i in range(16):                                     # 16 rounds
        [left, right] = nkey.divide_into_two()              # divide
        left << shifts_key_halvs[i]                         # shift
        right << shifts_key_halvs[i]                        # shift

        print ("%dleft  rk: %s"%(i, left.get_hex_string_from_bitvector()))
        print ("%dright rk: %s"%(i, right.get_hex_string_from_bitvector()))
        print (i,nkey)
        nkey = left + right                                 # join
        #print ('i={}, nkey={}'.format(i,nkey))
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

    print ("Feistel: %s"%(blah.get_hex_string_from_bitvector()))

    return blah                                     # p box permutation


def des(encrypt_or_decrypt, bitvec, key):
    # if (encrypt_or_decrypt == 'e'):
    #     file_length_bytes = pad_file(input_file)                                    # pad the file

    #bv = BitVector(filename=input_file)                                             # create bitvector

    #FILEOUT = open(output_file, 'wb')                                               # open output file

    # if (encrypt_or_decrypt == 'e'):
    #     print ("Starting Encryption:")
    # else:
    #     print ("Starting Decryption:")

    print (len(bitvec))
    print (bitvec)

    round_key = extract_round_key(key)                                              # grab the round keys



    for i, k in enumerate(round_key):
        print ("Round %2d Key: %s"%(i, k.get_hex_string_from_bitvector()))

    # out = BitVector(size=0)

    bitvec = bitvec.permute(init_perm)

    [LE, RE] = bitvec.divide_into_two()                                         # split

    for i in range(16):                                                         # 16 rounds
        old_RE = RE       
        print ("\n-----------Round %d------------\n"%(i))   
        print ("roundkey: %s\n"%(round_key[i].get_hex_string_from_bitvector()))

        #print ("%15s %15s\n"%(LE.get_hex_string_from_bitvector(), RE.get_hex_string_from_bitvector()))                                                   # temp
        print ("%10s %10s\n"%(LE.get_hex_string_from_bitvector(), RE.get_hex_string_from_bitvector()))                                                   # temp

        if (encrypt_or_decrypt == 'e'):                                         # choose correct round key
            RE = LE ^ fiesty_feistel(RE, round_key[i])
        else:
            RE = LE ^ fiesty_feistel(RE, round_key[15 - i])

        LE = old_RE                                                             # flip sides

    finished_bv = RE + LE      

    print (finished_bv.get_hex_string_from_bitvector())                                                 # merge two halves

    finished_bv = finished_bv.permute(init_perm_inv)

    # out += finished_bv

    print ("FINISHED: %s"%(finished_bv.get_hex_string_from_bitvector()))



        # if encrypt_or_decrypt == 'd':                                               # unpad if decrypting, and write to
        #     #unpadded_string = unpad_string(finished_bv.get_text_from_bitvector())   #   file
        #     unpadded_string = finished_bv.get_hex_string_from_bitvector()
        #     #FILEOUT.write(unpadded_string)
        #     #FILEOUT.close()
        #     return unpadded_string
        # else:
        #     #finished_bv.write_to_file(FILEOUT)
        #     return finished_bv.get_hex_string_from_bitvector()

    return finished_bv



################################## padding ######################################

def pad_file(input_file):
    short_bytes = 0
    with open(input_file) as f:
        file_length = len(f.read())
    if (file_length % 8 != 0):
        short_bytes = 8 - (file_length % 8)
        print ("padding with %d bytes" % short_bytes)
        with open(input_file, 'a') as f:
            for i in range(short_bytes):
                f.write(' ')               # pad with spaces
    return file_length + short_bytes


def unpad_string(padded_string):
    return padded_string.rstrip()

def tripleDES_enc(input_block, key_list, i):
    fout_input = open('inputblock_{}.txt'.format(i),'w')
    # fout_des1 = open('outputofdes_{}_1.txt'.format(i),'w')
    # fout_des2 = open('outputofdes_{}_2.txt'.format(i),'w')
    # fout_des3 = open('outputofdes_{}_3.txt'.format(i),'w')
    f_out_des = open('outputofdes_{}.txt'.format(i),'w')

    input_block.write_to_file(fout_input)

    out1 = des('e', input_block, key_list[0])

    out2 = des('e', out1, key_list[1])

    out3 = des('e', out2, key_list[2])

    out3.write_to_file(f_out_des)

    fout_input.close()
    f_out_des.close()


#################################### main ######################################

def main():

    key1 = BitVector(hexstring='af4892de13378520'.lower())
    key2 = BitVector(hexstring='beefdead1337abcd')
    key3 = BitVector(hexstring='1337abcdabcdabcd')

    # Sx = BitVector(hexstring='129e4d24 d07531e5 c99ffad6 7da90056 31c44b61 a'.replace(' ',''))
    # Sy = BitVector(hexstring='4927baba d5319b99 41617be0 17a7ee92 a188ce39 c'.replace(' ',''))

    # # input_block = BitVector(textstring='deadbeef')

    # one_nine_two_bit_key = Sx[0:163] + Sy[0:29]

    one_nine_two_bit_key = BitVector(hexstring='39c7311ac36911c635004adf35affcc9d3c6570592593ca4')
    print (len(one_nine_two_bit_key))

    key1 = one_nine_two_bit_key[0:64]
    key2 = one_nine_two_bit_key[64:128]
    key3 = one_nine_two_bit_key[128:192]

    print (one_nine_two_bit_key.get_hex_string_from_bitvector())

    # print (len(key1))
    # print (len(key2))
    # print (len(key3))


    key56_1 = get_encryption_key(key1)
    key56_2 = get_encryption_key(key2)
    key56_3 = get_encryption_key(key3)

    print(key56_1.get_hex_string_from_bitvector())
    print(key56_2.get_hex_string_from_bitvector())
    print(key56_3.get_hex_string_from_bitvector())


    # out1 = des('e', input_block, key56_1)

    # out2 = des('e', out1, key56_2)

    # out3 = des('e', out2, key56_3)

    # print (out3.get_hex_string_from_bitvector())


    data_bv = BitVector(intVal=0,size=64)

    out1 = des('e', data_bv, key56_1)

    out2 = des('e', out1, key56_2)

    out3 = des('e', out2, key56_3)

    # data_bv_list = [BitVector(intVal=random.randint(2**62, 2**64 - 1),size=64) for i in range(100)]
    # key_list = [key56_1, key56_2, key56_3]

    # # one_nine_two_bit_key = key1 + key2 + key3
    # keyout = open('192bitkey.txt','w')
    # one_nine_two_bit_key.write_to_file(keyout)

    # for i, bv in enumerate(data_bv_list):
    #     tripleDES_enc(bv, key_list, i)

    #open('inputblock.txt','wb').write(data_bv.get_hex_string_from_bitvector())

    # fout_input = open('inputblock.txt','w')
    # data_bv.write_to_file(fout_input)

    # out1 = des('e',data_bv, key56_1)  

    # # print ('output of decrypt:', des('d',out1,key56_1).get_hex_string_from_bitvector())

    # fout_des1 = open('outputofdes1.txt','w')
    # #open('outputofdes1.txt','wb').write(out1.get_hex_string_from_bitvector())
    # out1.write_to_file(fout_des1)


    # out2 = des('e',out1, key56_2)

    # #open('outputofdes2.txt','wb').write(out2.get_hex_string_from_bitvector())

    # fout_des2 = open('outputofdes2.txt','w')
    # #open('outputofdes1.txt','wb').write(out2.get_hex_string_from_bitvector())
    # out2.write_to_file(fout_des2)

    # out3 = des('e',out2, key56_3)

    # fout_des3 = open('outputofdes3.txt','w')
    # out3.write_to_file(fout_des3)

    # #open('outputofdes3.txt','wb').write(out3.get_hex_string_from_bitvector())

    # one_nine_two_bit_key = key1 + key2 + key3


    #open('192bitkey.txt','wb').write(one_nine_two_bit_key.get_hex_string_from_bitvector())


    #key = get_encryption_key(sys.argv[4])               # fetch the key from file specified by user

    # if (key is not None):
    #     des(sys.argv[1], sys.argv[2], sys.argv[3], key)     # apply des with either encryption or decryption, (argv[1])
    # else:
    #     print ("Error: Key is not of valid size")




    # EXAMPLE ENCRYPTION AND DECRYPTION WITH KEY 'sherlock'

    # input message
    # Shellshock, also known as Bashdoor, is a family of security bugs in the widely used Unix Bash shell,
    # the first of which was disclosed on 24 September 2014. Many Internet-facing services, such as some
    # web server deployments, use Bash to process certain requests, allowing an attacker to cause vulnerable
    # versions of Bash to execute arbitrary commands. This can allow an attacker to gain unauthorized access
    # to a computer system.


    # encrypted message

    # input message (HEX)
    # 5368656c6c73686f636b2c20616c736f206b6e6f776e2061732042617368
    # 646f6f722c20697320612066616d696c79206f6620736563757269747920
    # 6275677320696e2074686520776964656c79207573656420556e69782042
    # 617368207368656c6c2c20746865206669727374206f6620776869636820
    # 77617320646973636c6f736564206f6e2032342053657074656d62657220
    # 323031342e204d616e7920496e7465726e65742d666163696e6720736572
    # 76696365732c207375636820617320736f6d652077656220736572766572
    # 206465706c6f796d656e74732c20757365204261736820746f2070726f63
    # 657373206365727461696e2072657175657374732c20616c6c6f77696e67
    # 20616e2061747461636b657220746f2063617573652076756c6e65726162
    # 6c652076657273696f6e73206f66204261736820746f2065786563757465
    # 2061726269747261727920636f6d6d616e64732e20546869732063616e20
    # 616c6c6f7720616e2061747461636b657220746f206761696e20756e6175
    # 74686f72697a65642061636365737320746f206120636f6d707574657220
    # 73797374656d2e2020202020

    # encrypted message (HEX)
    # fddf016e17322db69920cdcb024005ffc11f2feeb5165e2ad8acb529fd78
    # 51f303c236dcd8496a1f57bdd39b768cf18f88513ec1595611da787fa0c6
    # 8613b6c34ced43c76d127dd7997912c2b3d2f3bdd2be38160b1b02e7bbc4
    # 793028f9821fbcf080dd751f91d28a38dfe6d3b4bf2390d6b7423b11a8fd
    # 879ade2cc19a80c5a88e89da483d48a2d94a94cca1461bf50882cb22f6c2
    # 1b492aed55cbd703555d5ce85f6df7a04f9863e1ffc1702a7536b50363cc
    # dbf331bf08acbebbff082e94a6cff5f16b5fe36fef3bd6982c1336fe15a8
    # ad7dd6e9b9c2dcd6c36e6c2def707424a5c7c2aa45f6769c064bac1697d3
    # d7eca59e22c1c89aba734c62cbc82f3a1c23803a5d71defee1532c83ef86
    # 1a8d08ab4c6235a8c786b5e420f0814c89121e1b7cf908e1ad80b62f2254
    # 0e17c4a8256c2c1a50425857b7c9272c4314dc4d6371818e827dd1e7acbc
    # 9b57c41ce4ec2d80372ee01dafc87e19c7d9b098d1ac93981e178c2abe10
    # b69c1ca24b686bcf3d512796dad4183723e75444f45d20e5c001c1da0eae
    # beed7c0c40914368ffb14e34d380c7282fb099454467387d770bd749c539
    # baf88ebe4e16559195058e07

    # decrypted message
    # Shellshock, also known as Bashdoor, is a family of security bugs in the widely
    # used Unix Bash shell, the first of which was disclosed on 24 Sept14. Many Internet-facing services,
    # such as some web server deployments, use Bash to process certain requests, allowing an attacker to
    # cause vulnerable versions of Bash to execute arbitrary commands. This can allow an attacker to gain
    # unauthorized access to a computer system.




if __name__ == "__main__":
    main()

