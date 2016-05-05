// $Id: $
// File name:   gf_Mult.sv
// Created:     3/18/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Galoid Field Multiplication

module gf_Mult
#(
  parameter NUM_BITS = 163
 )
(
  input wire clk, 
  input wire n_rst,
  input wire start,
  input wire [NUM_BITS:0] A,
  input wire [NUM_BITS:0] B,
  output reg [NUM_BITS:0] Product,
  output reg done
);

typedef enum logic [2:0] {IDLE, GETDATA, CALC, DONE} state_type;
state_type state, nextstate;

reg [(NUM_BITS * 2): 0]next_product, product;
reg [(NUM_BITS * 2): 0]midVal, next_midVal;
reg [(NUM_BITS): 0]midValB, next_midValB;
reg [8:0]count, next_count;


//Apply resets and get the next value
always_ff @(posedge clk, negedge n_rst)
begin: StateReg
if(n_rst == 0)
  begin
    state <= IDLE;
    product <= 0;
    midVal <= 0;
    midValB <= 0;
    count <= 0;
  end
  else 
  begin
    state <= nextstate;
    product <= next_product;
    midVal <= next_midVal;
    midValB <= next_midValB;
    count <= next_count;
  end
end 

//Next State Logic
always_comb
begin
  next_midVal = midVal;
  next_midValB = midValB;
  next_count = count;
  next_product = product;
  done = 0;
  nextstate = state;
  case(state)

      //If Start signal is given, go to the next state
      IDLE: begin
        next_count = 0;
        if(start == 1)
        begin
          next_product = 0;
          nextstate = GETDATA;
        end       
        else
          nextstate = IDLE;
      end

      //Grab the values
      GETDATA: begin
          nextstate = CALC;
          next_midVal = A;
          next_midValB = B;
      end

      //Start the calculation, we have to 163 mults hence the counter
      //Shift the previous value by 1, the size of midVal is double the size of the input
      //Xor it with prodduct if the B bit is set
      //Shift B by one on every iteration, this allows us to grab the 0th Bit always of B
      CALC: begin
          next_count = count + 1;
          next_product = product ^ (midVal  & {(2*NUM_BITS) {midValB[0]}});
          next_midVal = midVal << 1;
          next_midValB = midValB >> 1;
          nextstate = CALC;          
          if(count == 162)
          begin
            nextstate = DONE;
          end
      end

      //Set the done signal
      DONE: begin
          next_count = 0;
          nextstate = IDLE;
          done = 1;
      end
  endcase
end

//Instantiate the mod block
gf_Mod MOD
  (
    .poly({25'b0, product}),
    .rr_poly(Product)
  );

endmodule
