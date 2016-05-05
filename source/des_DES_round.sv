// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: DES CODE

module des_DES_round (
	input logic  [0:31] input_left,
	input logic  [0:31] input_right,
	input logic  [0:47] round_key,
	input logic data_valid_in,
	input logic clk,
	input logic n_rst,
	output logic data_valid_out,
	output logic [0:31] output_left,
	output logic [0:31] output_right
);

logic [0:31] f_out;

logic  [0:31] input_left_reg;
logic  [0:31] input_right_reg;

logic [0:47] actual_round_key;

logic data_valid_reg;

// registers for DES_round
// form the 48 stage pipeline for triple DES
always_ff @(posedge clk, negedge n_rst) 
begin
	if (n_rst == 0)
	begin
		input_left_reg <= f_out; // resets to f_out so that when it is xored with f_out it yields zero
		input_right_reg <= 0;
		data_valid_reg <= 0;
	end
	else if(data_valid_in == 0)
	begin
		input_left_reg <= f_out;
		input_right_reg <= 0;
		data_valid_reg <= 0;
	end
	else
	begin
		input_left_reg <= input_left;
		input_right_reg <= input_right;
		data_valid_reg <= data_valid_in;
    end
end

des_feistel F(
	.f_input_wires (input_right_reg),
	.round_key     (round_key),
	.f_output_wires(f_out)
	);

// assign outputs
assign output_left = input_right_reg;
assign output_right = input_left_reg ^ f_out;
assign data_valid_out = data_valid_reg;

endmodule
