// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: DES CODE

module des_key_permutation1 (
	input logic [0:63] input_wires,
	output logic [0:55] output_wires
);

	// applies the key permutation 1
	// 64 bit key --> 56 bit key
	assign output_wires[0] = input_wires[56];
	assign output_wires[1] = input_wires[48];
	assign output_wires[2] = input_wires[40];
	assign output_wires[3] = input_wires[32];
	assign output_wires[4] = input_wires[24];
	assign output_wires[5] = input_wires[16];
	assign output_wires[6] = input_wires[8];
	assign output_wires[7] = input_wires[0];
	assign output_wires[8] = input_wires[57];
	assign output_wires[9] = input_wires[49];
	assign output_wires[10] = input_wires[41];
	assign output_wires[11] = input_wires[33];
	assign output_wires[12] = input_wires[25];
	assign output_wires[13] = input_wires[17];
	assign output_wires[14] = input_wires[9];
	assign output_wires[15] = input_wires[1];
	assign output_wires[16] = input_wires[58];
	assign output_wires[17] = input_wires[50];
	assign output_wires[18] = input_wires[42];
	assign output_wires[19] = input_wires[34];
	assign output_wires[20] = input_wires[26];
	assign output_wires[21] = input_wires[18];
	assign output_wires[22] = input_wires[10];
	assign output_wires[23] = input_wires[2];
	assign output_wires[24] = input_wires[59];
	assign output_wires[25] = input_wires[51];
	assign output_wires[26] = input_wires[43];
	assign output_wires[27] = input_wires[35];
	assign output_wires[28] = input_wires[62];
	assign output_wires[29] = input_wires[54];
	assign output_wires[30] = input_wires[46];
	assign output_wires[31] = input_wires[38];
	assign output_wires[32] = input_wires[30];
	assign output_wires[33] = input_wires[22];
	assign output_wires[34] = input_wires[14];
	assign output_wires[35] = input_wires[6];
	assign output_wires[36] = input_wires[61];
	assign output_wires[37] = input_wires[53];
	assign output_wires[38] = input_wires[45];
	assign output_wires[39] = input_wires[37];
	assign output_wires[40] = input_wires[29];
	assign output_wires[41] = input_wires[21];
	assign output_wires[42] = input_wires[13];
	assign output_wires[43] = input_wires[5];
	assign output_wires[44] = input_wires[60];
	assign output_wires[45] = input_wires[52];
	assign output_wires[46] = input_wires[44];
	assign output_wires[47] = input_wires[36];
	assign output_wires[48] = input_wires[28];
	assign output_wires[49] = input_wires[20];
	assign output_wires[50] = input_wires[12];
	assign output_wires[51] = input_wires[4];
	assign output_wires[52] = input_wires[27];
	assign output_wires[53] = input_wires[19];
	assign output_wires[54] = input_wires[11];
	assign output_wires[55] = input_wires[3];

endmodule
