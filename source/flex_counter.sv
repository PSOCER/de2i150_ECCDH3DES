// $Id: $
// File name:   flex_counter.sv
// Created:     1/28/2015
// Author:      Xiong-Yao Zha
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Flexible and Scalable Counter with Controlled Rollover.

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	// Input
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [(NUM_CNT_BITS - 1) : 0] rollover_val,

	// Output
	output wire [(NUM_CNT_BITS - 1) : 0] count_out,
	output reg rollover_flag
);

// Count value
reg [(NUM_CNT_BITS - 1) : 0] count;
reg [(NUM_CNT_BITS - 1) : 0] next_count;
reg next_rollover_flag;

assign count_out = count;
	
// Flip flop
always_ff @ (posedge clk, negedge n_rst) 
begin:CT
	if (1'b0 == n_rst)
	begin
		count <= 0;
		rollover_flag <= 0;
	end 
	else
	begin 
		count <= next_count;
		rollover_flag <= next_rollover_flag;
	end
end	

// Combinational
always_comb
begin : LOGIC
	next_count = count;
	next_rollover_flag = rollover_flag;
	
	if (clear) 
	begin
		next_count = 0;
		next_rollover_flag = 0;
	end
	else if (count_enable) 
	begin
		next_count = count + 1;
		
		if (count >= rollover_val - 1)
		begin
			next_rollover_flag = 1;	
		end
		
		if (rollover_flag) 
		begin
			next_count = 1;
			next_rollover_flag = 0;
		end

	end
end	
endmodule
