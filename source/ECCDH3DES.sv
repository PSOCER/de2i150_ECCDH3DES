// $Id: $
// File name:   ECCDH3DES.sv
// Created:     4/15/2015
// Author:      Lucas Dahl
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Top Level block

module ECCDH3DES
(
	input wire clk,
	input wire n_rst,

	//DES
	input wire [63:0] raw_data,
	input wire data_valid_in,
	output wire data_valid_out,
	input wire is_encrypt,

	output reg [63:0] encrypted_data,

	//CONT
	input wire ecc1_start,
	input wire ecc2_start,
	input wire des_start,

	output reg ecc1_done,
	output reg ecc2_done,
	output reg des_done,

	output reg [163:0] PuX,
	output reg [163:0] PuY,

	//ECC
	input wire [163:0] PX,
	input wire [163:0] PY,
	input wire [163:0] k
);

	reg estart;
	reg edone;

	reg [163:0] Skx;
	reg [163:0] Sky;

	reg [191:0] keys;

	//point_multiplication block is the module that handles all ECC operations

	point_multiplication ECC(.clk(clk), .n_rst(n_rst), .k(k), .x(PX), .y(PY), .SkX(Skx), .SkY(Sky), .start(estart), .done(edone));

	//controller module is in charge of whether ECC or 3DES is running.
	controller CONT(.clk(clk), .n_rst(n_rst), .ecc_start1(ecc1_start), .ecc_start2(ecc2_start), .des_start(des_start), .estart(estart), .Pox(Skx), .Poy(Sky), .edone(edone), .Keys(keys), .PuX(PuX), .PuY(PuY), .ecc1_done(ecc1_done), .ecc2_done(ecc2_done), .des_done(des_done));

	//TripleDES is the module that encrypts all data sent in
	des_TripleDES DES(.clk(clk), .n_rst(n_rst), .input_block(raw_data), .Sk(keys), .output_block(encrypted_data), .data_valid_in(data_valid_in), .data_valid_out(data_valid_out), .is_encrypt(is_encrypt));

endmodule