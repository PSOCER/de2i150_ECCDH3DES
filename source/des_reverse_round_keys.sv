// $Id: mg78 $
// Created:     3/31/2015 
// Author:      Nico Bellante
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: DES CODE

module des_reverse_round_keys(
	input [0:15][0:47] round_keys,
	output [0:15][0:47] reversed_round_keys
);

genvar i;

generate
	for (i=0;i<16;i++)
	begin: REVFOR
		assign reversed_round_keys[i] = round_keys[15-i];
	end
endgenerate

endmodule