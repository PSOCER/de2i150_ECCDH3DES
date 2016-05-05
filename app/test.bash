#! /bin/bash

# load drivers
cd drivers/
./load_terasic_qsys_pcie_driver.sh
cd ../

# make project
make 

# generate private keys
./main -r pri_key/pri_A.txt
./main -r pri_key/pri_B.txt

# generate public keys
./main -g pri_key/pri_A.txt pub_key_local/pub_A.txt
./main -g pri_key/pri_B.txt pub_key_local/pub_B.txt

# diffie hellman
cp pub_key_local/pub_A.txt pub_key_external/pub_A.txt
cp pub_key_local/pub_B.txt pub_key_external/pub_B.txt

# A encrypts file
./main -e pri_key/pri_A.txt pub_key_external/pub_B.txt test_input.txt cipher_text/encrypted.txt

# run after reprogram and reboot
# B decrypts file
# ./main -d pri_key/pri_B.txt pub_key_external/pub_A.txt cipher_text/encrypted.txt plain_text/decrypted.txt

# diff test_input.txt plain_text/decrypted.txt
