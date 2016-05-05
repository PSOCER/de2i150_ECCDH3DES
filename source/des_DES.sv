// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: DES CODE

module des_DES (
	input logic [0:63] input_block,
	input logic [0:15][0:47] round_keys,
	input logic clk,
	input logic n_rst,
	input logic data_valid_in,
	output logic data_valid_out,
	output logic [0:63] output_block
);

genvar i; // Used to loop for the 16 rounds of des

logic [0:16][0:31] left ; // left and right, 32 bits each, 16 rounds
logic [0:16][0:31] right;
logic [0:16] data_valid; // data valid bits

logic [0:63] after_initial_permutation; // stores the input block after initial permutation


// initial permutation of des
des_initial_permutation ip (
	.input_wires(input_block),
	.output_wires(after_initial_permutation)
	);

// inverse initial permuation of des
des_inverse_initial_permutation invip (
	.input_wires({right[16], left[16]}),
	.output_wires(output_block)
	);

assign left[0]    = after_initial_permutation[0:31]; // assign left and right to be the result of the initial permutation
assign right[0]   = after_initial_permutation[32:63];
assign data_valid[0] = data_valid_in; // assign the data valid bits accordingly
assign data_valid_out = data_valid[16];

generate
	for (i=0; i<16; i++) // loop over the 16 rounds of des
	begin: DESROUNDFOR
		des_DES_round DES_R(
			.input_left  (left[i]),
			.input_right (right[i]),
			.round_key   (round_keys[i]),
			.clk         (clk),
			.n_rst       (n_rst),
			.data_valid_in  (data_valid[i]),
			.data_valid_out (data_valid[i+1]),
			.output_left (left[i+1]),
			.output_right(right[i+1])
			);
	end
endgenerate



endmodule
