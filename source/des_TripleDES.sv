// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: DES CODE

module des_TripleDES (
	input logic [0:63] input_block,
	input logic [0:191] Sk,
	input logic is_encrypt,
	input wire clk,
	input wire n_rst,
	input wire data_valid_in,
	output wire data_valid_out,
	output logic [0:63] output_block
);

logic [0:15][0:47] round_keys_1;
logic [0:15][0:47] round_keys_2;
logic [0:15][0:47] round_keys_3;

logic [0:63] DES1_output;
logic [0:63] DES2_output;

logic data_valid_out_1;
logic data_valid_out_2;

// instantiate key_sched 
des_key_schedule KS (
	.Sk(Sk),
	.is_encrypt(is_encrypt),
	.round_keys_1(round_keys_1),
	.round_keys_2(round_keys_2),
	.round_keys_3(round_keys_3)
	);

// instantiate des1
des_DES DES1 (
	.input_block     (input_block),
	.round_keys      (round_keys_1),
	.output_block    (DES1_output),
	.clk         	 (clk),
	.n_rst 			 (n_rst),
	.data_valid_in   (data_valid_in),
	.data_valid_out  (data_valid_out_1)
	);

// instantiate des2
des_DES DES2 (
	.input_block	(DES1_output),
	.round_keys 	(round_keys_2),
	.output_block   (DES2_output),
	.clk            (clk),
	.n_rst          (n_rst),
	.data_valid_in  (data_valid_out_1),
	.data_valid_out (data_valid_out_2)
	);

// instantiate des3
des_DES DES3 (
	.input_block     (DES2_output),
	.round_keys 	 (round_keys_3),
	.output_block    (output_block),
	.clk             (clk),
	.n_rst           (n_rst),
	.data_valid_in   (data_valid_out_2),
	.data_valid_out  (data_valid_out)
	);

endmodule
