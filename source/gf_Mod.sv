// $Id: $
// File name:   gf_Mod.sv
// Created:     4/1/2015
// Author:      Xiong-yao Zha
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Reduction modulo for Galois Fields.
module gf_Mod
#(
	parameter NUM_BITS = 163
)
(
	// Input
	input wire [351:0] poly,

	// Output
	output wire [163:0] rr_poly
);

	// Input
	reg [31:0] g10;
	reg [31:0] g09;
	reg [31:0] g08;
	reg [31:0] g07;
	reg [31:0] g06;
	reg [31:0] g05;
	reg [31:0] g04;
	reg [31:0] g03;
	reg [31:0] g02;
	reg [31:0] g01;
	reg [31:0] g00;

	// Chunk down input
	assign g10 = poly[351:320];
	assign g09 = poly[319:288];
	assign g08 = poly[287:256];
	assign g07 = poly[255:224];
	assign g06 = poly[223:192];
	assign g05 = poly[191:160];
	assign g04 = poly[159:128];
	assign g03 = poly[127:96];
	assign g02 = poly[95:64];
	assign g01 = poly[63:32];
	assign g00 = poly[31:0];

	// Intermediate variables
	reg [31:0] o_g06;
	reg [31:0] o_g05;
	reg [31:0] o_g04;
	reg [31:0] o_g03;
	reg [31:0] o_g02;
	reg [31:0] o_g01;
	reg [31:0] o_g00;

	reg [31:0] t;
	reg [31:0] tt;
	reg [31:0] oo_g00;
	reg [31:0] ooo_g00;
	reg [31:0] oo_g01;
	reg [31:0] oo_g05;

	// Output
	reg [191:0] r_poly;

	// Output
	assign r_poly[191:160] = oo_g05;
	assign r_poly[159:128] = o_g04;
	assign r_poly[127:96]  = o_g03;
	assign r_poly[95:64]   = o_g02;
	assign r_poly[63:32]   = oo_g01;
	assign r_poly[31:0]    = ooo_g00;

	assign rr_poly = r_poly[163:0];

	// Combinational 
	always_comb
	begin
		// Implement algorithm
		o_g06 = g06 ^ (g10 >> 28) ^ (g10 >> 29);
		o_g05 = g05 ^ (g10 >> 3) ^ (g10 << 4) ^ (g10 << 3) ^ g10 ^ (g09 >> 28) ^ (g09 >> 29);
		o_g04 = g04 ^ (g10 << 29) ^ (g09 >> 3) ^ (g09 << 4) ^ (g09 << 3) ^ g09 ^ (g08 >> 28) ^ (g08 >> 29);
		o_g03 = g03 ^ (g09 << 29) ^ (g08 >> 3) ^ (g08 << 4) ^ (g08 << 3) ^ g08 ^ (g07 >> 28) ^ (g07 >> 29);
		o_g02 = g02 ^ (g08 << 29) ^ (g07 >> 3) ^ (g07 << 4) ^ (g07 << 3) ^ g07 ^ (g06 >> 28) ^ (g06 >> 29);
		o_g01 = g01 ^ (g07 << 29) ^ (g06 >> 3) ^ (g06 << 4) ^ (g06 << 3) ^ g06;
		o_g00 = g00 ^ (g06 << 29);

		t = o_g05 >> 3;
		oo_g00 = o_g00 ^ t;
		tt = t << 3;
		oo_g01 = o_g01 ^ (tt >> 28) ^ (tt >> 29);
		ooo_g00 = oo_g00 ^ tt ^ (tt << 4) ^ (tt << 3);
		oo_g05 = o_g05 ^ tt;
	end

endmodule