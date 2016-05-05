// $Id: $
// File name:   tb_gf_Mult.sv
// Created:     3/19/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for gfMultiplication


`timescale 1ns / 100ps
module tb_gf_Mult
(
);
	localparam NUM_BITS = 163;	
	localparam NUM_INPUT_BITS = 3;
	localparam CLK_PERIOD = 5;
	localparam ROLLOVER_VAL = 10;
	localparam NUM_TEST_CASES = 10;
	localparam CHECK_DELAY = 1; // Check 1ns after the rising edge to allow for propagation delay

	// Declare test bench signals
	reg tb_tx_out;
	reg tb_clk;
	reg tb_n_rst;
	reg tb_ready;
	reg [3:0]tb_test_num;
	reg [3:0]i;
	reg [NUM_BITS:0]tb_A;
	reg [NUM_BITS:0]tb_B;
	reg [NUM_BITS:0]tb_product;
	reg tb_done;

	// DUT Port maps
	gf_Mult DUT(.A(tb_A), .B(tb_B), .Product(tb_product), .start(tb_ready), .clk(tb_clk), .n_rst(tb_n_rst), .done(tb_done));

	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	// Test bench process
	initial
	begin		
		tb_A = 164'h10101010000;
		tb_B = 164'h50005000;
	
		tb_ready = 0;


		// Power-on Reset of the DUT
		#(0.1);
		tb_n_rst	= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
		#(CLK_PERIOD * 2.25);	// Release the reset away from a clock edge
		tb_n_rst	= 1'b1; 	// Deactivate the chip reset

		// Wait for a while to see normal operation
		#(CLK_PERIOD);

		tb_ready = 1;
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_ready = 0;
	end


endmodule
