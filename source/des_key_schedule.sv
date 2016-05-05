// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: key schedule block

module des_key_schedule (
	input logic [0:191] Sk,
	input logic is_encrypt,
	output logic [0:15][0:47] round_keys_1,
	output logic [0:15][0:47] round_keys_2,
	output logic [0:15][0:47] round_keys_3
);

// temp round keys
logic [0:15][0:47] temp_round_keys_1;
logic [0:15][0:47] temp_round_keys_2;
logic [0:15][0:47] temp_round_keys_3;

// 3 56 bit keys
logic [0:55] Sk1; 
logic [0:55] Sk2; 
logic [0:55] Sk3; 

// instantiates 3 key permutation blocks 
des_key_permutation1 KP1U1 (
	.input_wires (Sk[0:63]),
	.output_wires(Sk1)
	);

des_key_permutation1 KP1U2 (
	.input_wires (Sk[64:127]),
	.output_wires(Sk2)
	);

des_key_permutation1 KP1U3 (
	.input_wires (Sk[128:191]),
	.output_wires(Sk3)
	);

des_generate_round_keys GRKU1 (
	.input_key(Sk1),
	.is_encrypt(is_encrypt),
	.round_keys(temp_round_keys_1)
	);

des_generate_round_keys GRKU2 (
	.input_key(Sk2),
	.is_encrypt(is_encrypt),
	.round_keys(temp_round_keys_2)
	);

des_generate_round_keys GRKU3 (
	.input_key(Sk3),
	.is_encrypt(is_encrypt),
	.round_keys(temp_round_keys_3)
	);


// reverse round keys if decryption
assign round_keys_1 = is_encrypt ? temp_round_keys_1 : temp_round_keys_3;
assign round_keys_3 = is_encrypt ? temp_round_keys_3 : temp_round_keys_1;
assign round_keys_2 = temp_round_keys_2;

endmodule
