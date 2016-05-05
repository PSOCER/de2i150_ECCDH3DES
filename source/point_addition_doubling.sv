// $Id: $
// File name:   point_addition.sv
// Created:     3/22/2015
// Author:      Xiong-yao Zha
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Point Addition and Multiplication Block.

module point_addition_doubling
#(
	parameter NUM_BITS = 163
)
(
	// Input
	input wire clk, 
	input wire n_rst,

	// Input wires
	input wire [NUM_BITS:0] x, // initial point
	input wire [NUM_BITS:0] y, // initial point

	input wire [NUM_BITS:0] x1, // projective coordinates
	input wire [NUM_BITS:0] z1, // projective coordinates

	input wire [NUM_BITS:0] x2, // projective coordinates
	input wire [NUM_BITS:0] z2, // projective coordinates

	input wire [NUM_BITS:0] b, // constant

	// Output wires
	output reg [NUM_BITS:0] x3, // projective coordinates
	output reg [NUM_BITS:0] z3, // projective coordinates

	// Mode selection
	input wire [1:0] mode,
	/*
		00 -> IDLE
		01 -> ADDITION
		10 -> MULTIPLICATION
		11 -> CONVERSION FROM PROJECTIVE TO AFFIINE
	*/

	// Start signal
	input wire start,

	// Output signal
	output wire done
);

	// States
	typedef enum bit[5:0] {
		IDLE,

		// States for addition
		A_M1,
		A_M2,
		A_A1,
		A_S1,
		A_M3,
		A_M4,
		A_A2,

		// States for doubling
		D_S1,
		D_S2,
		D_S3,
		D_S4,
		D_M1,
		D_M2,
		D_A1,
		D_S5,

		// States for conversion from projective to affine
		M_D1,
		M_M1,
		M_A1,
		M_M2,
		M_A2,
		M_M3,
		M_S1,
		M_A3,
		M_M4,
		M_M5,
		M_A4,
		M_M6,
		M_M7,
		M_D2,
		M_A5,
		M_M8,
		M_A6,

		// Done states
		A_DONE,
		D_DONE,
		M_DONE,

		DONE
	} stateType;

	// STATE VARIABLE
	stateType state;
	stateType next_state;

	// OUTPUT
	reg [NUM_BITS:0] next_x3;
	reg [NUM_BITS:0] next_z3;


	// ADDER
	reg [NUM_BITS:0] a1;
	reg [NUM_BITS:0] a2;
	reg [NUM_BITS:0] a3;

	reg [NUM_BITS:0] next_a1;
	reg [NUM_BITS:0] next_a2;

	// MULTIPLIER
	reg [NUM_BITS:0] m1;
	reg [NUM_BITS:0] m2;
	reg [NUM_BITS:0] m3;

	reg [NUM_BITS:0] next_m1;
	reg [NUM_BITS:0] next_m2;
	reg m_start;
	reg m_done;

	// SQUARE
	reg [NUM_BITS:0] s1;
	reg [NUM_BITS:0] s2;

	reg [NUM_BITS:0] next_s1;

	// DIVIDER
	reg [NUM_BITS:0] d1;
	reg [NUM_BITS:0] d2; 
	reg [NUM_BITS:0] d3;

	reg [NUM_BITS:0] next_d1;
	reg [NUM_BITS:0] next_d2;
	reg d_start;
	reg d_done;

	// PARTIAL REGISTERS
	reg [NUM_BITS:0] o_m1;
	reg [NUM_BITS:0] o_m2;
	reg [NUM_BITS:0] next_o_m1;
	reg [NUM_BITS:0] next_o_m2;

	reg [NUM_BITS:0] o_a1;
	reg [NUM_BITS:0] next_o_a1;

	reg [NUM_BITS:0] o_s2;
	reg [NUM_BITS:0] o_s4;
	reg [NUM_BITS:0] next_o_s2;
	reg [NUM_BITS:0] next_o_s4;

	reg [NUM_BITS:0] o_d1;
	reg [NUM_BITS:0] next_o_d1;

	// STATE TRANSITION
	always_ff @ (negedge n_rst, posedge clk)
	begin : MOORE
		if (1'b0 == n_rst)
		begin
			state <= IDLE;
			a1 <= 0;
			a2 <= 0;
			m1 <= 0;
			m2 <= 0;
			s1 <= 0;
			d1 <= 0;
			d2 <= 0;

			o_m1 <= 0;
			o_m2 <= 0;
			o_s2 <= 0;
			o_s4 <= 0;
			o_a1 <= 0;
			o_d1 <= 0;

			x3 <= 0;
			z3 <= 0;
		end
		else
		begin
			state <= next_state;

			a1 <= next_a1;
			a2 <= next_a2;
			m1 <= next_m1;
			m2 <= next_m2;
			s1 <= next_s1;
			d1 <= next_d1;
			d2 <= next_d2;

			o_m1 <= next_o_m1;
			o_m2 <= next_o_m2;
			o_s2 <= next_o_s2;
			o_s4 <= next_o_s4;
			o_a1 <= next_o_a1;
			o_d1 <= next_o_d1;

			x3 <= next_x3;
			z3 <= next_z3;
		end
	end

	// Combinational block
	always_comb
	begin : NEXT_STATE
		next_state = state;
		next_a1 = a1;
		next_a2 = a2;
		next_m1 = m1;
		next_m2 = m2;
		next_s1 = s1;
		next_d1 = d1;
		next_d2 = d2;

		next_o_m1 = o_m1;
		next_o_m2 = o_m2;
		next_o_s2 = o_s2;
		next_o_s4 = o_s4;
		next_o_a1 = o_a1;
		next_o_d1 = o_d1;

		next_x3 = x3;
		next_z3 = z3;

		// STATES to implement equations
		case(state)
			IDLE:
			begin
				if ( start == 1'b1 && mode == 2'b01) 
					next_state = A_M1;
				else if (start == 1'b1 && mode == 2'b10)
					next_state = D_S1;
				else if (start == 1'b1 && mode == 2'b11)
					next_state = M_D1;
				else 
					next_state = IDLE;
			end

			A_M1:
			begin
				if ( m_done == 1'b1)
				begin
					next_state = A_M2;
					next_o_m1 = m3;
				end
				else
					next_state = A_M1;

				next_m1 = x1;
				next_m2 = z2;
			end

			A_M2:
			begin
				if ( m_done == 1'b1)
				begin
					next_state = A_A1;
					next_o_m2 = m3;
				end
				else
					next_state = A_M2;

				next_m1 = x2;
				next_m2 = z1;
			end

			A_A1:
			begin
				next_state = A_S1;

				next_a1 = o_m1;
				next_a2 = o_m2;

				next_m1 = o_m1;
				next_m2 = o_m2;
			end

			A_S1:
			begin
				next_state = A_M3;

				next_s1 = a3;
			end

			A_M3:
			begin
				if ( m_done == 1'b1)
				begin
					next_state = A_M4;
					next_o_m1 = m3;

					// MULT MULT MULT
					next_m1 = x;
					next_m2 = s2;
				end
				else
					next_state = A_M3;

				next_z3 = s2;
			end

			A_M4:
			begin
				if ( m_done == 1'b1)
				begin
					next_state = A_A2;
					next_o_m2 = m3;
				end
				else
					next_state = A_M4;
			end

			A_A2:
			begin
				next_state = A_DONE;

				next_a1 = o_m1;
				next_a2 = o_m2;
			end


			D_S1:
			begin
				next_state = D_S2;

				next_s1 = x2;

				// MULT MULT MULT
				next_m1 = x2;
				next_m2 = z2;
			end

			D_S2:
			begin
				next_state = D_S3;

				next_s1 = s2;
			end


			D_S3:
			begin
				next_state = D_S4;

				next_o_s2 = s2;
				next_s1 = z2;
			end

			D_S4:
			begin
				next_state = D_M1;

				next_s1 = s2;
			end

			D_M1:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m1 = m3;
					next_state = D_M2;
				end
				else
					next_state = D_M1;
				next_o_s4 = s2; 
			end

			D_M2:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m2 = m3;
					next_state = D_A1;
				end
				else
					next_state = D_M2;
				next_m1 = o_s4;
				next_m2 = b;
			end

			D_A1:
			begin
				next_state = D_S5;

				next_a1 = o_m2;
				next_a2 = o_s2;
			end

			D_S5:
			begin				
				next_state = D_DONE;

				next_x3 = a3; 
				next_s1 = o_m1;
			end

			M_D1:
			begin
				if ( d_done == 1'b1)
				begin
					next_x3 = d3;
					next_state = M_M1;
				end
				else
					next_state = M_D1;
				next_d1 = x1;
				next_d2 = z1;
			end

			M_M1:
			begin
				if ( m_done == 1'b1)
				begin 
					next_o_m1 = m3;
					next_state = M_A1;
				end
				else
					next_state = M_M1;
				next_m1 = x;
				next_m2 = z1;
			end

			M_A1:
			begin
				next_state = M_M2;
				next_a1 = x1;
				next_a2 = o_m1;
			end

			M_M2:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m1 = m3;
					next_state = M_A2;
				end
				else
					next_state = M_M2;
				next_m1 = x;
				next_m2 = z2;
				next_o_a1 = a3;
			end

			M_A2:
			begin
				next_state = M_M3;
				next_a1 = x2;
				next_a2 = o_m1;
			end

			M_M3:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m1 = m3;
					next_state = M_S1;
				end
				else
					next_state = M_M3;
				next_m1 = o_a1;
				next_m2 = a3;
			end

			M_S1:
			begin
				next_state = M_A3;
				next_s1 = x;
			end 

			M_A3:
			begin
				next_state = M_M4;
				next_a1 = y;
				next_a2 = s2;
			end

			M_M4:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m2 = m3;
					next_state = M_M5;
				end
				else 
					next_state = M_M4;
				next_m1 = z1;
				next_m2 = z2;
				next_o_a1 = a3;
			end

			M_M5:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m2 = m3;
					next_state = M_A4;
				end
				else
					next_state = M_M5;
				next_m1 = o_a1;
				next_m2 = o_m2;
			end

			M_A4:
			begin
				next_state = M_M6;
				next_a1 = o_m2;
				next_a2 = o_m1;
			end

			M_M6:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m1 = m3;
					next_state = M_M7;
				end
				else
					next_state = M_M6;
				next_m1 = z1;
				next_m2 = z2;
				next_o_a1 = a3;
			end

			M_M7:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m1 = m3; 
					next_state = M_D2;
				end
				else
					next_state = M_M7;
				next_m1 = x;
				next_m2 = o_m1;
			end

			M_D2:
			begin
				if ( d_done == 1'b1)
				begin
					next_o_d1 = d3;
					next_state = M_A5;
				end
				else
					next_state = M_D2;
				next_d1 = o_a1;
				next_d2 = o_m1;
			end

			M_A5:
			begin
				next_state = M_M8;
				next_a1 = x;
				next_a2 = x3;
			end

			M_M8:
			begin
				if ( m_done == 1'b1)
				begin
					next_o_m1 = m3;
					next_state = M_A6;
				end
				else
					next_state = M_M8;
				next_m1 = o_d1;
				next_m2 = a3; 
			end

			M_A6:
			begin
				next_state = M_DONE;
				next_a1 = o_m1;
				next_a2 = y;
			end

			M_DONE:
			begin
				next_state = DONE;
				next_z3 = a3;
			end

			D_DONE:
			begin
				next_state = DONE;
				next_z3 = s2;
			end

			A_DONE:
			begin
				next_state = DONE;
				next_x3 = a3;
			end

			DONE:
			begin
				next_state = IDLE;
			end

		endcase
	end

	// Start signal for Galois multiplication
	assign m_start = (state == A_M1 || state == A_M2 || state == A_M3 || state == A_A1 || state == A_S1 || state == A_M4 || state == D_S1 || state == D_S2 || state == D_S3 || state == D_M1 || state == D_M2 || state == M_M1 || state == M_M2 || state == M_M3 || state == M_M4 || state == M_M5 || state == M_M6 || state == M_M7 || state == M_M8);
	
	// Start signal for Galois division
	assign d_start = (state == M_D1 || state == M_D2);

	// Done signal for Point Multiplication
	assign done = (state == DONE);

	// Galois arithmetics
	gf_Add 
	#(
		.NUM_BITS(NUM_BITS)
	)
	ADDER (
		.A  (a1),
		.B  (a2),
		.Sum(a3)
	);

	gf_Mult
	#(
		.NUM_BITS(NUM_BITS)
	)
	MULTIPLIER (
		.clk	(clk),
		.n_rst  (n_rst),
		.A      (m1),
		.B      (m2),
		.Product(m3),
		.start  (m_start),
		.done   (m_done)
	);

	gf_Square
	#(
		.NUM_BITS(NUM_BITS)	
	)
	SQUARE (
		.A      (s1),
		.Squared(s2)
	);

	gf_Div
	#(
		.NUM_BITS(NUM_BITS)
	)
	DIVIDER (
		.clk  (clk),
		.n_rst(n_rst),
		.A    (d1),
		.B    (d2),
		.Q    (d3),
		.start(d_start),
		.done (d_done)
	);

endmodule
