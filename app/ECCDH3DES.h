// File name : ECCDH3DES.h
// Author : Xiong-Yao Zha, Manish Gupta
// Created : 03/29/2015
// Version 1.0 
// Description : Base functions for FPGA interface

#ifndef ECCDH3DES_H
#define ECCDH3DES_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#include "PCIE.h"

//MAX BUFFER FOR DMA
#define MAXDMA 32

//BASE ADDRESS FOR CONTROL REGISTER
#define CRA 0x00000000		// This is the starting address of the Custom Slave module. This maps to the address space of the custom module in the Qsys subsystem.

//BASE ADDRESS TO SDRAM
#define SDRAM 0x08000000	// This is the starting address of the SDRAM controller. This maps to the address space of the SDRAM controller in the Qsys subsystem.
#define START_BYTE 0xF00BF00B
#define RWSIZE (32 / 8)

// FUNCTION
DWORD csr_registers(char);
char get_Index(char);
char convert_Hex(char);
void read_Key_File(FILE *, DWORD *);
void set_Registers(PCIE_HANDLE, char, DWORD *);
void get_Registers(PCIE_HANDLE, char, DWORD *);

void get_Public_Keys(PCIE_HANDLE, DWORD *, DWORD *, DWORD *, DWORD *, DWORD *);
void generate_Session_Keys(PCIE_HANDLE, DWORD *, DWORD *, DWORD *);

void print_164bits_file(FILE *, DWORD *);
void print_164bits(DWORD *);
void print_string_hex(char *);
DWORD endian_Convert(DWORD);
void print_Read(DWORD, FILE *);

void write_SRAM(PCIE_HANDLE, FILE *, int);
void read_SRAM(PCIE_HANDLE, FILE *, int);
void des(PCIE_HANDLE, FILE *, FILE*, char);
#endif
