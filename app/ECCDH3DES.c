// File name : ECCDH3DES.c
// Author : Xiong-Yao Zha, Manish Gupta
// Created : 03/29/2015
// Version 1.0 
// Description : Base functions for FPGA interface

#include "ECCDH3DES.h"


DWORD csr_registers(char i) 
{
    return CRA + (i * 4);
}


char get_Index(char var)
{
    if ( var == 'K' )
    {
        return 1;
    }
    else if( var == 'Y' ) 
    {
        return 7;
    }
    else if ( var == 'X' )
    {
        return 13;
    }
    else if ( var == 'x' )
    {
        return 20;
    }
    else if ( var == 'y' )
    {
        return 26;
    }
    else
    {
        return 0;
    }
}

char convert_Hex(char c)
{
    char hexVal = 0;

    if(c >= '0' && c <= '9')
    {
        hexVal = c - '0';
    }
    else if (c >= 'a' && c <= 'f')
    {
        hexVal = c - 'a' + 10;
    }
    else if (c >= 'A' && c <= 'F')
    {
        hexVal = c - 'F' + 10;
    }
    else
    {
        hexVal = 0;
    }

    return hexVal;
}

void read_Key_File(FILE * fh, DWORD * inKey)
{
    char inputBuf[8];
    int i = 0;
    int j = 0;

    for(j= 0; j < 6; j++)
    {
        inKey[j] = 0;
    }

    for(j = 0; j < 5; j++)
    {
        fread(inputBuf, 1, 8, fh);
        for(i = 0; i < 4; i++)
        {
            inKey[j] |= (convert_Hex(inputBuf[i*2]) << (28 - i*8)) | (convert_Hex(inputBuf[(i*2)+1])  << (24 - i*8)); 
        }
    }

    fread(&inputBuf[0], 1, 1, fh);
    inKey[5] = convert_Hex(inputBuf[0]) << 28;
}

void set_Registers(PCIE_HANDLE hPCIe, char var, DWORD * a)
{
    BOOL bPass;
    char r; 
    int i;

    r = get_Index(var);

    for ( i = 0 ; i < 6 ; i ++ ) 
    {
        bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(r + i), a[i]);
        if (!bPass)
        {
            printf("Error: PCIE_Write32 in set_Registers.\n");
            return;
        }
    }
}


void get_Registers(PCIE_HANDLE hPCIe, char var, DWORD * a)
{
    BOOL bPass;
    char r; 
    int i;

    r = get_Index(var);

    for ( i = 0 ; i < 6 ; i ++ ) 
    {
        bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(r + i), &a[i]);
        if (!bPass)
        {
            printf("Error: PCIE_Read32 in get_Registers.\n");
            return;
        }
    }
}


void get_Public_Keys(PCIE_HANDLE hPCIe, DWORD * x, DWORD * y, DWORD * k, DWORD * PuX, DWORD * PuY)
{   
    BOOL bPass;
    char ecc_1_done = 0;  
    
    DWORD ecc_1;

    // PX
    set_Registers(hPCIe, 'X', x);

    // PY
    set_Registers(hPCIe, 'Y', y);

    // K
    set_Registers(hPCIe, 'K', k);


    // START ECC1
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(0), 0x00000001);
    if (!bPass)
    {
        printf("Error: PCIE_Write32 in get_Public_Keys.\n");
        return;
    }

    while(!ecc_1_done) 
    {
        bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(0), &ecc_1);
        if (!bPass)
        {
            printf("Error: PCIE_Read32 in get_Public_Keys.\n");
            return;
        }
        ecc_1_done = ((ecc_1 >> 31) & 0x01);
    }

    // CLEAR START ECC1
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(0), ecc_1 & 0xFFFFFFFE);
    if (!bPass)
    {
        printf("Error: PCIE_Write32 in get_Public_Keys.\n");
        return;
    }

    // GET PUX
    get_Registers(hPCIe, 'x', PuX);

    // GET PUY
    get_Registers(hPCIe, 'y', PuY);
}


void generate_Session_Keys(PCIE_HANDLE hPCIe, DWORD * x, DWORD * y, DWORD * k)
{
    BOOL bPass;
    char ecc_2_done = 0;  
    
    DWORD ecc_2;

    // PX
    set_Registers(hPCIe, 'X', x);

    // PY
    set_Registers(hPCIe, 'Y', y);

    // K
    set_Registers(hPCIe, 'K', k);


    // START ECC2
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(0), 0x00000002);
    if (!bPass)
    {
        printf("Error: PCIE_Write32 in generate_Session_Keys.\n");
        return;
    }

    while(!ecc_2_done) 
    {
        bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(0), &ecc_2);
        if (!bPass)
        {
            printf("Error: PCIE_Read32 in generate_Session_Keys.\n");
            return;
        }
        ecc_2_done = ((ecc_2 >> 25) & 0x01);
    }

    // CLEAR START ECC1
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(0), ecc_2 & 0xFFFFFFFD);
    if (!bPass)
    {
        printf("Error: PCIE_Write32 in generate_Session_Keys.\n");
        return;
    }
}


void print_164bits(DWORD * a)
{
    int i;

    for ( i = 0; i < 6; i ++ )
    {
        printf("%08x ", a[i]);
    }
    printf("\n");
}

void print_164bits_file(FILE * fh, DWORD * a)
{

	int i;

	for ( i = 0; i < 5; i ++ )
	{
		fprintf(fh, "%08x", a[i]);
	}
	fprintf(fh, "%01x", (a[i] >> 28) & 0xf);
}


DWORD endian_Convert(DWORD buffer)
{
    buffer = ((buffer << 16) & 0xffff0000) | ((buffer >> 16) & 0x0000ffff);
    buffer = ((buffer << 8) & 0xff00ff00) | ((buffer >> 8) & 0x00ff00ff);

    return buffer;
}

void print_Read(DWORD r, FILE * fp)
{
    fprintf(fp, "%c", (r >> 24) & 0xFF);
    fprintf(fp, "%c", (r >> 16) & 0xFF);
    fprintf(fp, "%c", (r >>  8) & 0xFF);
    fprintf(fp, "%c", (r )      & 0xFF);
}

void write_SRAM(PCIE_HANDLE hPCIe, FILE * fp, int fileSize)
{
    int x;

    BOOL bPass;

    DWORD upper;
    DWORD lower;
    DWORD r;

    for(x = 0; x < fileSize; x += 8) 
    {
        upper = 0;
        lower = 0;

        // Read in 4 bytes
        fread(&upper, 1, 4, fp);

        // Read in 4 bytes
        fread(&lower, 1, 4, fp);

        //Swap
        upper = endian_Convert(upper);
        lower = endian_Convert(lower);

        // Write to register
        bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(37), upper);
        if (!bPass)
        {
            printf("Error: PCIE_Write32 in write_SRAM.\n");
            return;
        }

        // Write to register
        bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(36), lower);
        if (!bPass)
        {
            printf("Error: PCIE_Write32 in write_SRAM.\n");
            return;
        }

        // Set written flag
        bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(35), 0x00000001);
        if (!bPass)
        {
            printf("Error: PCIE_Write32 in write_SRAM.\n");
            return;
        }

        // Wait to be read
        char s_read = 0;
        while(!s_read) 
        {
            bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(35), &r);
            if (!bPass)
            {
                printf("Error: PCIE_Read32 in write_SRAM.\n");
                return;
            }
            s_read = ((r >> 31) & 0x01);
        }

        // Clear register
        bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(35), 0x00000000);
        if (!bPass)
        {
            printf("Error: PCIE_Write32 in write_SRAM.\n");
            return;
        }
    }
    
    // Send fileSize
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(41), (x/8) + 1);
    if (!bPass)
    {
        printf("test FAILED: read did not return success\n");
        return;
    }
    return;
}

void read_SRAM(PCIE_HANDLE hPCIe, FILE * fp, int fileSize)
{
    int x;

    BOOL bPass;

    DWORD r;

    for(x = 0; x < fileSize; x += 8)
    {
        // Wait for slave to write
        char s_write = 0;
        while(!s_write) 
        {
            bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(38), &r);
            if (!bPass)
            {
            printf("Error: PCIE_Read32 in read_SRAM.\n");
                return;
            }
            s_write = r & 0x01;
        }

        // Read
        bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(40), &r);
        if (!bPass)
        {
            printf("Error: PCIE_Read32 in read_SRAM.\n");
            return;
        }

        print_Read(r, fp);

        // Read
        bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(39), &r);
        if (!bPass)
        {
            printf("Error: PCIE_Read32 in read_SRAM.\n");
            return;
        }

        print_Read(r, fp);

        // Set Read flag
        bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(38), 0x80000000);
        if (!bPass)
        {
            printf("Error: PCIE_Write32 in read_SRAM.\n");
            return;
        }
    }

    return;
}

void des(PCIE_HANDLE hPCIe,  FILE * fin, FILE * fout, char encryption)
{
    BOOL bPass;
    
    DWORD des;
    char des_done = 0;

    // Determine file size
    fseek(fin, 0, SEEK_END);
    int fileSize = ftell(fin);

    // Reset pointer to head of file
    fseek(fin, 0, SEEK_SET);
    printf("Writing to SRAM...\n");

    // Write to SRAM from file
    write_SRAM(hPCIe, fin, fileSize);

    // Set des start (bit 3) /encryption (bit 4)
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(0), 0x00000004 | (encryption << 3));
    if (!bPass)
    {
        printf("Error: PCIE_Write32 in des.\n");
        return;
    }

    printf("Waiting for DES to complete...\n");
    while(!des_done) 
    {
        bPass = PCIE_Read32(hPCIe, PCIE_BAR0, csr_registers(0), &des);
        if (!bPass)
        {
        printf("Error: PCIE_Read32 in des.\n");
            return;
        }
        des_done = ((des >> 24) & 0x01);
    }

    // Set start read
    bPass = PCIE_Write32(hPCIe, PCIE_BAR0, csr_registers(45), 0x80000000);
    if (!bPass)
    {
        printf("Error: PCIE_Write32 in read_SRAM.\n");
    }
    
    // Read from SRAM into buffer
    printf("Reading from SRAM...\n");
    read_SRAM(hPCIe, fout, fileSize);
}