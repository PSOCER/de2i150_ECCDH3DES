// $Id: $
// File name:   gf_Square.sv
// Created:     4/2/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Galois Field Squaring .

module gf_Square
#(
	parameter NUM_BITS = 163
 )
(
  input wire [NUM_BITS:0] A,
  output reg [NUM_BITS:0] Squared
);


reg [(NUM_BITS * 2): 0]product;
reg [(NUM_BITS * 2): 0]midVal;


integer i;
always_comb
begin
	midVal = 0;
	for(i = 0; i < NUM_BITS; i++)
	begin
		midVal[2*i] = A[i];
	end
end

gf_Mod MOD(.poly({25'b0, midVal}), .rr_poly(Squared));

endmodule
