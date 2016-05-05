// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: generate round keys

module des_generate_round_keys(
	input logic [0:55] input_key,
	input logic is_encrypt,
	output logic [0:15][0:47] round_keys
);
	
logic [0:15][0:27] left;
logic [0:15][0:27] right;
logic [0:15][0:47] temp_round_keys;
logic [0:15][0:47] reversed_round_keys;

// assign left and right to be shifted concatenated versions of input key as per DES standards
assign left[0] = {input_key[1:27], input_key[0]};
assign left[1] = {input_key[2:27], input_key[0:1]};
assign left[2] = {input_key[4:27], input_key[0:3]};
assign left[3] = {input_key[6:27], input_key[0:5]};
assign left[4] = {input_key[8:27], input_key[0:7]};
assign left[5] = {input_key[10:27], input_key[0:9]};
assign left[6] = {input_key[12:27], input_key[0:11]};
assign left[7] = {input_key[14:27], input_key[0:13]};
assign left[8] = {input_key[15:27], input_key[0:14]};
assign left[9] = {input_key[17:27], input_key[0:16]};
assign left[10] = {input_key[19:27], input_key[0:18]};
assign left[11] = {input_key[21:27], input_key[0:20]};
assign left[12] = {input_key[23:27], input_key[0:22]};
assign left[13] = {input_key[25:27], input_key[0:24]};
assign left[14] = {input_key[27], input_key[0:26]};
assign left[15] = input_key[0:27];

assign right[0] = {input_key[29:55], input_key[28]};
assign right[1] = {input_key[30:55], input_key[28:29]};
assign right[2] = {input_key[32:55], input_key[28:31]};
assign right[3] = {input_key[34:55], input_key[28:33]};
assign right[4] = {input_key[36:55], input_key[28:35]};
assign right[5] = {input_key[38:55], input_key[28:37]};
assign right[6] = {input_key[40:55], input_key[28:39]};
assign right[7] = {input_key[42:55], input_key[28:41]};
assign right[8] = {input_key[43:55], input_key[28:42]};
assign right[9] = {input_key[45:55], input_key[28:44]};
assign right[10] = {input_key[47:55], input_key[28:46]};
assign right[11] = {input_key[49:55], input_key[28:48]};
assign right[12] = {input_key[51:55], input_key[28:50]};
assign right[13] = {input_key[53:55], input_key[28:52]};
assign right[14] = {input_key[55], input_key[28:54]};
assign right[15] = input_key[28:55];

genvar i;

generate
	for (i=0; i<16; i++) // apply key permutation 2 on all of the formed keys
	begin: KEYPERM2
		des_key_permutation2 KP2U (
			.input_wires ({left[i], right[i]}),
			.output_wires(temp_round_keys[i])
			);
	end

endgenerate

// reverse round keys for decryption
des_reverse_round_keys RVRK (
	.round_keys(temp_round_keys),
	.reversed_round_keys(reversed_round_keys)
	);

// if encrypting, give the normal round keys as output. 
// if decrypting, give the reversed round keys as output
always_comb
begin
	if (is_encrypt == 1'b1)
		round_keys = temp_round_keys;
	else
		round_keys = reversed_round_keys;
end

endmodule
