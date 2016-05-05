// $Id: $
// File name:   point_multiplication.sv
// Created:     4/3/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Point Multiplication for ECC

module point_multiplication
#(
	parameter NUM_BITS = 163
)
(
	input wire clk,
	input wire n_rst,
	input wire [NUM_BITS:0] k,
	input wire [NUM_BITS:0] x,
	input wire [NUM_BITS:0] y,
	output reg [NUM_BITS:0] SkX,
	output reg [NUM_BITS:0] SkY,

	input wire start, 
	output wire done
);

	reg [NUM_BITS:0] X1,X2,Z1,Z2;

	
	typedef enum bit[4:0] {	IDLE,CHECK_DATA,INITIALIZE, SQUARE1, SQUARE2, CHECKKVAL, POINT_ADD1, GET_VALUES1, POINT_DOUBLE1, GET_VALUES2,  POINT_ADD2, GET_VALUES3, POINT_DOUBLE2, GET_VALUES4, CONVERTAFFINE, DONE} stateType;
	logic [8:0] count_out;
	logic [8:0] rollover_val;
	logic count_start;
	logic count_done;
	logic count_clear;
	logic pointAddDouble_start;
	logic pointAddDouble_done;
	logic [1:0]pointAddDouble_mode;
	logic [NUM_BITS:0] s1;
	logic [NUM_BITS:0] s2;
	logic [NUM_BITS:0] x2;
	logic [NUM_BITS:0] x1;
	logic [NUM_BITS:0] x3;
	logic [NUM_BITS:0] z1;
	logic [NUM_BITS:0] z2;
	logic [NUM_BITS:0] z3;
	logic [NUM_BITS:0] k_r;
	logic [NUM_BITS:0] b;


	logic [NUM_BITS:0] next_s1;
	logic [NUM_BITS:0] next_s2;
	logic [NUM_BITS:0] next_x1;
	logic [NUM_BITS:0] next_x2;
	logic [NUM_BITS:0] next_z1;
	logic [NUM_BITS:0] next_z2;
	logic [1:0] next_pointAddDouble_mode;
	logic next_pointAddDouble_start;
	logic [NUM_BITS:0] next_SkX;
	logic [NUM_BITS:0] next_SkY;

	assign b = 164'h20a601907b8c953ca1481eb10512f78744a3205fd;
	assign rollover_val = 10'd162;

	flex_counter #(.NUM_CNT_BITS(9)) count2(.clk(clk), .n_rst(n_rst), .clear(count_done | count_clear), .count_out(count_out),  .count_enable(count_start), .rollover_val(rollover_val), .rollover_flag(count_done));
	stateType state;
	stateType next_state;

	genvar i;
	generate
	for(i = 0; i <= NUM_BITS; i++)
	begin: REVERSEBITS
		assign k_r[NUM_BITS - i] = k[i];
	end

	endgenerate
	
	//Flip-flop logic
	always_ff @ (negedge n_rst, posedge clk)
	begin : MOORE
		if (1'b0 == n_rst)
		begin
			state <= IDLE;
			x1 <= 0;
			x2 <= 0;
			z1 <= 0;
			z2 <= 0;
			s1 <= 0;
			pointAddDouble_mode <= 0;	
			pointAddDouble_start <= 0;
			SkX <= 0;
			SkY <= 0;
		end
		else
		begin
			state <= next_state;

			x1 <= next_x1;
			x2 <= next_x2;
			z1 <= next_z1;
			z2 <= next_z2;	
			s1 <= next_s1;
			pointAddDouble_mode <= next_pointAddDouble_mode;	
			pointAddDouble_start <= next_pointAddDouble_start;
			SkX <= next_SkX;
			SkY <= next_SkY;
		end
	end

	//Next-state logic
	always_comb
	begin : NEXT_STATE
		next_state = state;
		next_x1 = x1;
		next_x2 = x2;
		next_z1 = z1;
		next_z2 = z2;
		next_s1 = s1;
		next_s2 = s2;
		next_SkX = SkX;
		next_SkY = SkY;
		next_pointAddDouble_start = pointAddDouble_start;
		next_pointAddDouble_mode = pointAddDouble_mode;
		count_clear = 0;
		count_start = 0;

		//Follows algorithm as shown
		case(state)
			IDLE:
			begin
				if ( start == 1'b1) 
					next_state = CHECK_DATA;
				else 
					next_state = IDLE;
			end

			CHECK_DATA:
			begin
				if ((k == 0) | (x == 0)) 
					next_state = DONE;
				else 
					next_state = INITIALIZE;
			end
			INITIALIZE:
			begin
				count_clear = 1;
				next_state = SQUARE1;
				next_x1 = x;
				next_z1 = 1;
				next_s1 = x;
				
			end
			SQUARE1:
			begin
				next_z2 = s2;
				next_s1 = s2;
				next_state = SQUARE2;
			end
			SQUARE2:
			begin
				next_x2 = s2;
				next_x2 = s2 ^ b;
				next_s1 = s1;
				next_state = CHECKKVAL;
				count_clear = 1;
			end
			CHECKKVAL:
			begin
				if(count_done)
				begin
					next_state = CONVERTAFFINE;
					next_pointAddDouble_start = 1;
					next_pointAddDouble_mode = 3;
				end	
				else
				begin
					if(k_r[count_out])
					begin
						next_x1 = x1;
						next_x2 = x2;
						next_z1 = z1;
						next_z2 = z2;
						next_pointAddDouble_start = 1;
						next_pointAddDouble_mode = 1;
						next_state = POINT_ADD1;
					end
					else
					begin
						next_x1 = x1;
						next_x2 = x2;
						next_z1 = z1;
						next_z2 = z2;
						next_pointAddDouble_start = 1;
						next_pointAddDouble_mode = 1;
						next_state = POINT_ADD2;
					
					end 		
				end
			end
			POINT_ADD1:
			begin
				if (pointAddDouble_done == 1'b1)
				begin
					next_state = GET_VALUES1;
				end
				else
				begin
					next_pointAddDouble_start = 0;
					next_state = POINT_ADD1;
				end
			end
			GET_VALUES1:
			begin
				next_pointAddDouble_start = 1;
				next_pointAddDouble_mode = 2;
				next_x1 = x3;
				next_z1 = z3;
				next_state = POINT_DOUBLE1;
			end
			POINT_DOUBLE1:
			begin
				if (pointAddDouble_done == 1'b1)
				begin
					next_pointAddDouble_start = 0;
					next_pointAddDouble_mode = 2;
					next_state = GET_VALUES2;
				end
				else
				begin
					next_pointAddDouble_start = 0;
					next_state = POINT_DOUBLE1;
				end
			end

			GET_VALUES2:
			begin
				next_pointAddDouble_start = 0;
				next_pointAddDouble_mode = 2;
				next_x2 = x3;
				next_z2 = z3;
				next_state = CHECKKVAL;
				count_start = 1;
			end


			POINT_ADD2:
			begin
				if (pointAddDouble_done == 1'b1)
				begin
					next_state = GET_VALUES3;
				end
				else
				begin
					next_pointAddDouble_start = 0;
					next_state = POINT_ADD2;
				end
			end
			GET_VALUES3:
			begin
				next_pointAddDouble_start = 1;
				next_pointAddDouble_mode = 2;
				next_x2 = x1;
				next_z2 = z1;
				next_x1 = x3;
				next_z1 = z3;
				next_state = POINT_DOUBLE2;
			end
			POINT_DOUBLE2:
			begin
				if (pointAddDouble_done == 1'b1)
				begin
					next_pointAddDouble_start = 0;
					next_pointAddDouble_mode = 2;
					next_state = GET_VALUES4;
				end
				else
				begin
					next_pointAddDouble_start = 0;
					next_state = POINT_DOUBLE2;
				end
			end

			GET_VALUES4:
			begin
				next_pointAddDouble_start = 0;
				next_pointAddDouble_mode = 2;
				next_x1 = x3;
				next_z1 = z3;
				next_x2 = x1;
				next_z2 = z1;
				next_state = CHECKKVAL;
				count_start = 1;
			end

			CONVERTAFFINE:
			begin	
				if (pointAddDouble_done == 1'b1)
				begin
					next_state = DONE;
					next_SkX = x3;
					next_SkY = z3;
				end
				else
				begin
					next_pointAddDouble_start = 0;
					next_state = CONVERTAFFINE;
				end
		
			end
	
			DONE:
			begin
				next_state = IDLE;	
			end
		endcase
	end

	assign done = (state == DONE);

	//Block Instantiations 
	gf_Square
	#(
		.NUM_BITS(NUM_BITS)	
	)
	SQUARE (
		.A      (s1),
		.Squared(s2)
	);

	point_addition_doubling
	#(
		.NUM_BITS(NUM_BITS)	
	)
	POINT_ADD_DOUBLE (
		
	.clk(clk), 
	.n_rst(n_rst),

	.b(b),
	.x(x), 
	.y(y),

	.x1(x1),
	.z1(z1),

	.x2(x2),
	.z2(z2),

	.x3(x3),
	.z3(z3),

	.mode(pointAddDouble_mode),
	.start(pointAddDouble_start),
	.done(pointAddDouble_done)
	);


endmodule

