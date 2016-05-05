// File name : main.c
// Author : Xiong-Yao Zha, Manish Gupta
// Created : 03/29/2015
// Version 1.0 
// Description : Main function that interfaces all the functionalities of the ECCDH3DES

#include "ECCDH3DES.h"

char convert_Option(char * option)
{
	if (option[0] != '-')
	{
		printf("First argument must be a flag\n");
		return -1;
	}

	switch(option[1])
	{
		case 'h' : return 0;
		case 'g' : return 1;
		case 'd' : return 2;
		case 'e' : return 3;
		case 'r' : return 4;
		default  : return -1;
	}

	return -1;
}

int main(int argc, char * argv[])
{

	//Check if correct argument set is passed in
	if(argc < 2)
	{
		printf("Usage: ./main -h for help\n");
		return 1;
	}
	
	// Input option
	char option = convert_Option(argv[1]);

	// Set up PCIE
	void * lib_handle;
	PCIE_HANDLE hPCIe;

	lib_handle = PCIE_Load();
	if (!lib_handle)
	{
		printf("PCIE_Load failed\n");
		return 0;
	}
	hPCIe = PCIE_Open(0,0,0);

	if (!hPCIe)
	{
		printf("PCIE_Open failed\n");
		return 0;
	}

	// Perform requestion option
	if( (option == 0) && (argc == 2) )
	{
		printf("To generate Public Key:\n");
		printf("\t./main -g <input>.txt <output>.txt\n");
		printf("\tInput: Private Key\n");
		printf("\tOutput: Public Key\n");

		printf("To encrypt/decrypt a file:\n");
		printf("\t./main -e/-d <private key>.txt <public key>.txt <input>.txt <output>.txt\n");
		printf("\t-e: Encrypt <input>.txt, and save to <output>.txt\n");
		printf("\t-d: Decrypt <input>.txt, and save to <output>.txt\n");
		
		printf("To generate random Private Key:\n");
		printf("\t./main -r <output>.txt\n");
		return 1;	
	}

	else if ( (option == 1) && (argc == 4) )
	{
	
		// X_1
		DWORD x_1[] = {0x3f0eba16, 0x286a2d57, 0xea099116, 0x8d499463, 0x7e8343e3, 0x60000000};
		
		// Y_1
		DWORD y_1[] = {0x0d51fbc6, 0xc71a0094, 0xfa2cdd54, 0x5b11c5c0, 0xc797324f, 0x10000000};
 
		// PRI
		DWORD * pri = malloc(sizeof(DWORD) * (6));
		
		// PUB_X
		DWORD * pub_x = malloc(sizeof(DWORD) * (6));

		// PUB_Y
		DWORD * pub_y = malloc(sizeof(DWORD) * (6));
		
		FILE * fin = fopen(argv[2], "r");
		read_Key_File(fin, pri);


		printf("Generating public key...\n");

		get_Public_Keys(hPCIe, x_1, y_1, pri, pub_x, pub_y);

		
		FILE * fout = fopen(argv[3], "w");

		print_164bits_file(fout, pub_x);
		fprintf(fout, "\n");
		print_164bits_file(fout, pub_y);

		free(pri);
		free(pub_x);
		free(pub_y);
		fclose(fin);
		fclose(fout);
	}

	else if ( (option == 2 || option == 3) && (argc == 6) )
	{
		// PRI
		DWORD * pri = malloc(sizeof(DWORD) * (6));
		
		// PUB_X
		DWORD * pub_x = malloc(sizeof(DWORD) * (6));

		// PUB_Y
		DWORD * pub_y = malloc(sizeof(DWORD) * (6));

		
		FILE * fin1 = fopen(argv[2], "r");
		read_Key_File(fin1, pri);

		FILE * fin2 = fopen(argv[3], "r");
		read_Key_File(fin2, pub_x);
		fgetc(fin2);
		read_Key_File(fin2, pub_y);

		printf("Generating session keys...\n");

		generate_Session_Keys(hPCIe, pub_x, pub_y, pri);
		
		// SRAM STUFF
		FILE * fin3 = fopen(argv[4], "rb");
		FILE * fout = fopen(argv[5], "w");

		printf("Performing 3DES...\n");

		// DES
		des(hPCIe, fin3, fout, option - 2);

		free(pri);
		free(pub_x);
		free(pub_y);
		fclose(fin1);
		fclose(fin2);
		fclose(fin3);
		fclose(fout);
	}
	
	else if ( (option == 4) && (argc == 3) )
	{	
		int i;
		int r;
		
		srand(time(NULL));

		FILE * fp = fopen(argv[2], "w");
		
		printf("Generating private key...\n");
		
		for (i = 0; i < 41; i ++)
		{
			r = rand() % 16;
			fprintf(fp, "%1x", r);
		}

		fclose(fp);
	}

	else
	{
		printf("Usage: ./main -h for help\n");
		return 1;	
	}

	PCIE_Close(hPCIe);
	return 0;
}
