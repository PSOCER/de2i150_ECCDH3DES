// $Id: $
// File name:   gf_Div.sv
// Created:     3/22/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Galois Field Division

module gf_Div
#(
	parameter NUM_BITS = 163 
)
(
	input wire clk,
  input wire n_rst,
  input wire [NUM_BITS:0] A,
  input wire [NUM_BITS:0] B,
  input wire start,
  output reg [NUM_BITS:0] Q,
  output reg done
);

typedef enum logic [4:0] {IDLE, GETDATA, DIVIDE, SQUARE1, SQUARE2, SQUARE3, SQUARE4, SQUARE5, SQUARE6, SQUARE7, SQUARE8, SQUARE9, SQUARE10, SQUARE11, MULT1, MULT2, MULT3, MULT4, MULT5, FINALMULT, DONE} state_type;
state_type state, nextstate;

logic [NUM_BITS:0] next_out1;
logic [NUM_BITS:0] next_inA, inA;
logic [NUM_BITS:0] next_inB, inB;
logic [NUM_BITS:0] next_inC, inC;
logic [NUM_BITS:0] next_inD;
logic [NUM_BITS:0] next_Q;
logic mul_start;
logic mul_done;
logic count_start;
logic count_done;
logic count_clear;
logic [8:0] rollover_val;
logic [8:0] count_out;

//Flipflop logic
always_ff @(posedge clk, negedge n_rst)
begin: StateReg
if(n_rst == 0)
  begin
	  state <= IDLE;
    Q <= 0;
    inA <= 0;
    inB <= 0;
    inC <= 0;
  end
	else 
  begin
    state <= nextstate;
    Q <= next_Q;
    inA <= next_inA;
    inB <= next_inB;
    inC <= next_inC;
  end
end 

//Next State logic
always_comb begin : nextState
	nextstate = state;
  done = 0;
  mul_start = 0;
  next_Q = Q;
  next_inA = inA;
  next_inB = inB;
  next_inC = inC;
  rollover_val = 0;
  count_clear = 0;
  count_start = 0;

  case(state)

    //Goes to next state if start
		IDLE: begin
			if(start == 1)
				nextstate = GETDATA;
			else
				nextstate = IDLE;
		end

    //Gets the data
    GETDATA: begin
		  next_inA = B;
		  next_inB = B;
			nextstate = SQUARE1;
    end

    //A=A^2
		SQUARE1: begin
      next_inA = next_out1;
      next_inB = next_out1;
      nextstate = SQUARE2;
		end

    //T=A^2
		SQUARE2: begin
      next_inA = next_out1;
      next_inC = next_out1;
      nextstate = SQUARE3;
		end
    //A = A*T,  T = T^2
		SQUARE3: begin
      mul_start = 1;
      if(mul_done)
      begin
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = MULT1;
      end
      else
        nextstate = SQUARE3;     
		end

    //A = A*T
		MULT1: begin
      mul_start = 1;
      if(mul_done)
      begin
        next_inA = next_inD;
        nextstate = SQUARE5;
        count_clear = 1;
      end
      else
        nextstate = MULT1;
		end

    //T = (A^2) ^ 3
		SQUARE5: begin
      mul_start = 0;
      rollover_val = 2;
      count_start = 1;  
      if(count_done)
      begin
        next_inA = next_out1;
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = SQUARE6;
        count_clear = 1;
      end
      else
      begin
        nextstate = SQUARE5;
        next_inA = next_out1;
      end
		end

    //A = A*T,  T = (T^2) ^ 3
		SQUARE6: begin
      mul_start = 1;
      rollover_val = 200;
      count_start = 1;
      if(mul_done)
      begin
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = MULT2;
        count_clear = 1;
      end
      else
      begin
        nextstate = SQUARE6;
        if(count_out <  2)  
          next_inA = next_out1;
      end  

		end

    //A = A*T step 9
		MULT2: begin
      mul_start = 1;
      if(mul_done)
      begin
        next_inA = next_inD;
        nextstate = SQUARE7;
        count_clear = 1;
      end
      else
        nextstate = MULT2;
		end

    //T = (A^2) ^ 9
		SQUARE7: begin
      mul_start = 0;
      rollover_val = 8;
      count_start = 1;
      if(count_done)
      begin
        next_inA = next_out1;
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = SQUARE8;
        count_clear = 1;
      end
      else
      begin
        nextstate = SQUARE7;
        next_inA = next_out1;
      end
		end

    //A = A*T,  T = (T^2) ^ 9
		SQUARE8: begin
      mul_start = 1;
      rollover_val = 200;
      count_start = 1;
      if(mul_done)
      begin
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = MULT3;
      end
      else
      begin
        nextstate = SQUARE8; 
        if(count_out <  8)  
          next_inA = next_out1;
      end  

		end

    //A = A*T step 13
		MULT3: begin
      mul_start = 1;
      if(mul_done)
      begin
        next_inA = next_inD;
        nextstate = SQUARE9;
        count_clear = 1;
      end
      else
        nextstate = MULT3;
		end

    //T = (A^2) ^ 27
		SQUARE9: begin
      mul_start = 0;
      rollover_val = 26;
      count_start = 1;
      if(count_done)
      begin
        next_inA = next_out1;
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = SQUARE10;
        count_clear = 1;
      end
      else
      begin
        nextstate = SQUARE9;
        next_inA = next_out1;
      end
		end





    //A = A*T,  T = (T^2) ^ 27
		SQUARE10: begin
      mul_start = 1;
      mul_start = 1;
      rollover_val = 200;
      count_start = 1;
      if(mul_done)
      begin
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = MULT4;
      end
      else
      begin
        nextstate = SQUARE10; 
        if(count_out <  26)  
          next_inA = next_out1;
      end  

		end

    //A = A*T step 17
		MULT4: begin
      mul_start = 1;
      if(mul_done)
      begin
        next_inA = next_inD;
        nextstate = SQUARE11;
        count_clear = 1;
      end
      else
        nextstate = MULT4;
		end

    //T = (A^2) ^ 81
		SQUARE11: begin
      mul_start = 0;
      rollover_val = 80;
      count_start = 1;
      if(count_done)
      begin
        next_inA = next_out1;
        next_inB = next_out1;
        next_inC = next_inD;        
        nextstate = MULT5;
        count_clear = 1;
      end
      else
      begin
        nextstate = SQUARE11;
        next_inA = next_out1;
      end
		end

    //A = A*T step 19
		MULT5: begin
      mul_start = 1;
      if(mul_done) begin
        nextstate = FINALMULT;
        next_inB = next_inD;
        next_inC = A;
      end
      else
        nextstate = MULT5;
		end


    FINALMULT: begin
      mul_start = 1;
      if(mul_done)
      begin
        nextstate = DONE;
        next_Q = next_inD;
      end
      else
        nextstate = FINALMULT;
    end

    //Set done signal
		DONE: begin
			nextstate = IDLE;
      done = 1;
		end
	endcase

end

//Instantiation of the Square Block
gf_Square Square
  (
    .A(inA), 
    .Squared(next_out1)
  );

//Instantiation of the Mult Block
gf_Mult Mult
  (
    .clk(clk), 
    .n_rst(n_rst),
    .A(inB), 
    .B(inC), 
    .start(mul_start), 
    .done(mul_done), 
    .Product(next_inD)
  );


//Instantiation of the Counter
flex_counter #(9) count1
  (
    .clk(clk),
    .n_rst(n_rst), 
    .clear(count_done | count_clear), 
    .count_out(count_out),  
    .count_enable(count_start), 
    .rollover_val(rollover_val), 
    .rollover_flag(count_done)
  );


endmodule
