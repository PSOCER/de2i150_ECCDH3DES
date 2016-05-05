// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Feistel Function for DES

module des_feistel (
	input wire [0:31] f_input_wires,
	input wire [0:47] round_key,
	output wire [0:31] f_output_wires
);

logic [0:47] expanded_f_input_wires;
logic [0:47] expanded_with_round_key;
logic [0:31] after_sbox;

// expansion permutation
des_expansion_permutation EXP (
	.input_wires (f_input_wires),
	.output_wires(expanded_f_input_wires)
	);

// xor round key
assign expanded_with_round_key = expanded_f_input_wires ^ round_key;

// sbox substitutions	
des_sbox_substitutions SBOX (
	.input_wires (expanded_with_round_key),
	.output_wires(after_sbox)
	);

// pbox permutations
des_pbox_permutations PBOX(
	.input_wires (after_sbox),
	.output_wires(f_output_wires)
	);

endmodule
