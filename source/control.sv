// $Id: $
// File name:   control.sv
// Created:     4/9/2015
// Author:      Lucas Dahl
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: controller for our project

module control
(
	input wire clk,
	input wire n_rst,
	input wire [63:0] data_in,
	input wire start,
	output reg [63:0] data_out,
	output reg [2:0] mode,
	output reg data_ready,
	input wire edone,
	input wire [163:0] Pox,
	input wire [163:0] Poy,
	output reg [163:0] k,
	output reg [163:0] Pix,
	output reg [163:0] Piy,
	output reg estart,
	input wire [63:0] DES_output,
	output reg [163:0] Skx,
	output reg [163:0] Sky,
	output reg [63:0] DES_input
);

	reg [5:0] count;
	reg [5:0] next_count;
	reg [511:0] data_block;
	reg rdone;
	//reg estart;
	//reg edone;
	//reg [163:0] k;
	//reg [163:0] Pix;
	//reg [163:0] Piy;
	//reg [163:0] Pox;
	//reg [163:0] Poy;
	//reg dstart;
	reg ddone;
	//reg is_encrypt;
	//reg [47:0][15:0] r_keys;

	typedef enum bit [2:0] {INIT, ECC1, MWAIT, GPUB, ECC2, DES} stateType;

	stateType state;
	stateType next_state;

	//point_multiplication ECC(.clk(clk), .n_rst(n_rst), .k(k), .x(Pix), .y(Piy), .SkX(Pox), .SkY(Poy), .start(estart), .done(edone));

	//TripleDES DES3(.input_block(data_in), .SKx(Pox), .SKy(Poy), .output_block(data_out));

	//assign data_block[447:0] = data_block[511:64];
	//assign data_block[511:448] = data_in;
	assign k = data_block[163:0];  
	assign Piy = data_block[327:164];
	assign Pix = data_block[491:328];

	assign data_ready = ddone;

	always_ff @ (posedge clk, negedge n_rst)
	begin : FLIPFLOP
		if (n_rst == 0)
		begin
			count <= 6'b0;
			state <= INIT;
			data_block <= 512'b0;
		end
		else
		begin
			data_block[511:64] <= data_block[447:0];
			//data_block[447:0] <= data_block[511:64];
			data_block[63:0] <= data_in; 
			count <= next_count;
			state <= next_state;
		end
	end

	always_comb
	begin: STATE_LOGIC
		next_state = state;
		
		case(state)
			INIT:
			begin
				if (rdone == 1'b1)
					next_state = ECC1;
				else
					next_state = INIT;
			end

			ECC1:
			begin
				next_state = edone ? MWAIT: ECC1;
				/*if (edone == 1'b1)
					next_state = MWAIT;
				else
					next_state = ECC1;*/
			end

			MWAIT:
			begin
				if (start == 1'b1)
					next_state = GPUB;
				else
					next_state = MWAIT;
			end

			GPUB:
			begin
				if (rdone == 1'b1)
					next_state = ECC2;
				else
					next_state = GPUB;
			end

			ECC2:
			begin
				if (edone == 1'b1)
					next_state = DES;
				else
					next_state = ECC2;
			end

			DES:
			begin
				if (start == 1'b0)
					next_state = MWAIT;
				else
					next_state = DES;
			end

		endcase
	end

	always_comb
	begin: ASSIGN_LOGIC
		estart = 1'b0;
		rdone = 1'b0;
		mode = 3'b0;
		ddone = 1'b0;
		//dstart = 1'b0;
		next_count = count;
		
		case(state)
			INIT:
			begin
				next_count = count + 1;
				mode = 3'b000;
				if (count == 6'b000111)
					rdone = 1'b1;
				else
					rdone = 1'b0;
			end

			ECC1:
			begin
				mode = 3'b001;
				estart = 1'b1;
			end

			MWAIT:
			begin
				next_count = 0;
				mode = 3'b010;
			end

			GPUB:
			begin
				next_count = count + 1;
				mode = 3'b011;
				if (count == 6'b000111)
					rdone = 1'b1;
				else
					rdone = 1'b0;
			end

			ECC2:
			begin
				next_count = 0;
				mode = 3'b100;
				estart = 1'b1;
			end

			DES:
			begin
				//next_count = count + 1;
				//dstart = 1'b1;
				mode = 3'b101;
				if (count == 6'd50)
					begin
					ddone = 1'b1;
					next_count = count;
					end
				else
					begin
					ddone = 1'b0;
					next_count = count + 1;
					end
			end

		endcase
	end

endmodule







