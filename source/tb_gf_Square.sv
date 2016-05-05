// $Id: $
// File name:   tb_gf_Mult.sv
// Created:     3/19/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for gfMultiplication


`timescale 1ns / 100ps
module tb_gf_Square
(
);
	localparam NUM_BITS = 163;	
	localparam NUM_INPUT_BITS = 3;
	localparam CLK_PERIOD = 10;
	localparam ROLLOVER_VAL = 10;
	localparam NUM_TEST_CASES = 10;
	localparam CHECK_DELAY = 1; // Check 1ns after the rising edge to allow for propagation delay

	// Declare test bench signals
	reg tb_tx_out;
	reg [1:0] tb_sda_mode;
	reg tb_sda_out;
	reg [3:0]tb_test_num;
	reg [3:0]i;
	reg [NUM_BITS:0]tb_A;
	reg [NUM_BITS:0]tb_squared;
	reg tb_done;

	
	// DUT Port maps
	gf_Square DUT(.A(tb_A), .Squared(tb_squared));


	// Test bench process
	initial
	begin
		tb_A = {1'b0, 1'b1, 1'b1, 153'b0, 1'b1, 1'b1, 2'b0, 1'b1, 2'b0, 1'b1};
		#(5);			
		tb_A = {1'b0, 1'b0, 1'b0, 153'b0, 1'b0, 1'b1, 2'b1, 1'b1, 2'b0, 1'b1};
		
		
	end


endmodule
