// $Id: $
// File name:   tb_control.sv
// Created:     4/22/2015
// Author:      Lucas Dahl
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb for controller

`timescale 1ns / 1ps

module tb_controller();

	parameter CLK_PERIOD = 5;

	reg tb_clk;
	reg tb_n_rst;
	reg tb_ecc_start1;
	reg tb_ecc_start2;
	reg tb_des_start;
	reg tb_estart;
	reg [163:0] tb_Pox;
	reg [163:0] tb_Poy;
	reg tb_edone;
	reg [191:0] tb_Keys;
	reg [163:0] tb_PuX;
	reg [163:0] tb_PuY;
	reg tb_ecc1_done;
	reg tb_ecc2_done;
	reg tb_des_done;

	integer i;
	
	controller DUT(.clk(tb_clk), .n_rst(tb_n_rst), .ecc_start1(tb_ecc_start1), .ecc_start2(tb_ecc_start2), .des_start(tb_des_start), .estart(tb_estart), .Pox(tb_Pox), .Poy(tb_Poy), .edone(tb_edone), .Keys(tb_Keys), .PuX(tb_PuX), .ecc1_done(tb_ecc1_done), .ecc2_done(tb_ecc2_done), .des_done(tb_des_done));


	always
	begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2);
	end


//tests all three start bits for a done signal

	initial
	begin
		tb_ecc_start1 = 1'b0;
		tb_ecc_start2 = 1'b0;
		tb_des_start = 1'b0;		
		tb_n_rst = 1'b0;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_n_rst = 1'b1;
		#CLK_PERIOD;
		#CLK_PERIOD;
		//state should be idle here
		tb_ecc_start1 = 1'b1;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_ecc_start1 = 1'b0;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_edone = 1'b1;
		//state should go to ecc1_done		
		#CLK_PERIOD;
		#CLK_PERIOD;
		//state should be IDLE
		tb_edone = 1'b0;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_ecc_start2 = 1'b1;
		#CLK_PERIOD;
		//in state ECC2
		#CLK_PERIOD;
		tb_ecc_start2 = 1'b0;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_edone = 1'b1;		
		//state should go to ecc2_done
		#CLK_PERIOD;
		#CLK_PERIOD;
		//state should be IDLE
		tb_edone = 1'b0;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_des_start = 1'b1;
		//state should go to KEY_WAIT1
		#CLK_PERIOD;
		#CLK_PERIOD;
		for (i = 0; i<6'd48; i++)
			#CLK_PERIOD;
			
		#CLK_PERIOD;
		#CLK_PERIOD;
		#CLK_PERIOD;
		#CLK_PERIOD;
		tb_des_start = 1'b0;
		//State should go to DES_DONE
		#CLK_PERIOD;
		for (i = 0; i<6'd48; i++)
			#CLK_PERIOD;
		//State should be IDLE
			
	end

endmodule







