// $Id: $
// File name:   gf_add.sv
// Created:     3/22/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Galois Field Addition

module gf_Add
#(
	parameter NUM_BITS = 8
)
(
  input wire [NUM_BITS:0] A,
  input wire [NUM_BITS:0] B,
  output reg [NUM_BITS:0] Sum
);

	assign Sum = A ^ B;

endmodule
