// $Id: $
// File name:   controller.sv
// Created:     4/20/2015
// Author:      Lucas Dahl
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: controller for our ECCDH3DES

module controller
(
	input wire clk,
	input wire n_rst,

	//INPUT
	input wire ecc_start1,		//3 start bits
	input wire ecc_start2,
	input wire des_start,

	//ECC
	output reg estart,

	input wire [163:0] Pox, //output keys of ECC
	input wire [163:0] Poy, 
	input wire edone,

	//DES
	output reg [0:191] Keys,			//session keys
	//output reg is_encrypt,

	//OUTPUT
	output reg [163:0] PuX,			//public keys
	output reg [163:0] PuY,

	output reg ecc1_done, 		//3 done bits
	output reg ecc2_done,
	output reg des_done
);
	
	reg [5:0] count;
	reg [5:0] next_count;
	reg next_des_done;
	reg [163:0] next_PuX;
	reg [163:0] next_PuY;
	reg [163:0] PubX;
	reg [163:0] PubY;

	typedef enum bit [3:0] {IDLE, ECC1, ECC2, ECC1_DONE, ECC2_DONE, DES_DONE, KEY_WAIT1, KEY_WAIT2, INIT_WAIT, DATA_WAIT, FIN_WAIT} stateType;

	stateType state;
	stateType next_state;

	// assign Keys[162:0] = Pox[162:0];
	// assign Keys[191:163] = Poy[28:0];

	assign Keys[0:191] = {Pox[162:0],Poy[28:0]};

	assign PuX = PubX;
	assign PuY = PubY;

	//assign des_done = (state == DES_DONE || state == DATA_WAIT);

	always_ff @ (posedge clk, negedge n_rst)
	begin : FLIPFLOP
		if (n_rst == 0)
		begin

			count <= 6'd0;
			state <= IDLE;
			PubX <= 0;
			PubY <= 0;
			des_done <= 0;
		end
		else
		begin
			count <= next_count;
			state <= next_state;
			des_done <= next_des_done;
			PubX <= next_PuX;
			PubY <= next_PuY;
		end
	end

	always_comb
	begin: STATE_LOGIC
		next_state = state;
		next_count = count;
		
		case(state)
			//IDLE state chooses which operation will be done
			IDLE:
			begin
				if (ecc_start1 == 1'b1)
					next_state = ECC1;
				else if (ecc_start2 == 1'b1)
					next_state = ECC2;
				else if (des_start == 1'b1)
					next_state = KEY_WAIT1;
				else
					next_state = state;
			end

			//ECC1 is creating the public key of a private key

			ECC1:
			begin
				if (edone == 1'b1)
					next_state = ECC1_DONE;
				else 
					next_state = ECC1;
			end

			//ECC2 is creating the session keys

			ECC2:
			begin
				if (edone == 1'b1)
					next_state = ECC2_DONE;
				else 
					next_state = ECC2;
			end

			//both done states signal that the ECC is done

			ECC1_DONE:
			begin
				next_state = IDLE;
			end

			ECC2_DONE:
			begin
				next_state = IDLE;
			end
	
			//Key wait is waiting for the DES to create the  round keys

			KEY_WAIT1:
			begin
				if (count == 6'd9)
				begin
					next_state = KEY_WAIT2;
					next_count = 6'd0;
				end
				else
				begin
					next_state = KEY_WAIT1;
					next_count = count + 1;
				end
			end

			KEY_WAIT2:
			begin
				next_state = INIT_WAIT;
			end

			//INIT wait is waiting 48 cycles for the first chunk of data to be encrypted

			INIT_WAIT:
			begin
				if (count == 6'd48)
				begin
					next_state = DATA_WAIT;
					next_count = 0;
				end
				else
				begin
					next_state = INIT_WAIT;
					next_count = count + 1;
				end
			end

			//DATA_Wait is waiting for the all of the data to be sent to the 3DES 

			DATA_WAIT:
			begin
				if(des_start == 1'b0)
				begin
					next_state = FIN_WAIT;
				//	next_count = 1;
				end
				else
				begin
					next_state = DATA_WAIT;
				//	if(count >= 6'd2)
				//		next_count = 1;
				//	else
				//		next_count = count + 1;
				end
			end

			//FIN_wait is waiting the final 48 cycles for the last data to be encrypted

			FIN_WAIT:
			begin
				if (count == 6'd48)			
				begin					
					next_count = 0;	
					next_state = DES_DONE;
					//des_done = 1'b1;
				end				
				else
				begin
					next_count = count + 1;
					next_state = FIN_WAIT;
				end
			end

			//DES_DOne is used to show that the DES has finished encrypting

			DES_DONE:
			begin
				next_state = IDLE;
			end

			//DES_DONE_2:
			//begin
			//	next_state = IDLE;
			//end

		endcase
	end

	//flags the  done signals when reaching a done state.
	//flags the start signal to start the  ECC module
	//des done will stay high until another des start is given

	always_comb
	begin: ASSIGN_LOGIC
		estart = 1'b0;
		ecc1_done = 1'b0;
		ecc2_done = 1'b0;
		//des_done = 1'b0;
		next_PuX = PubX;
		next_PuY = PubY;
		next_des_done = des_done;	
		
		case(state)
			KEY_WAIT1:
			begin
				next_des_done = 1'b0;
			end

			ECC1:
			begin 
				estart = 1'b1;
			end

			ECC2:
			begin
				estart = 1'b1;
			end

			ECC1_DONE:
			begin
				next_PuX = Pox;
				next_PuY = Poy;
				ecc1_done = 1'b1;
			end

			ECC2_DONE:
			begin
				ecc2_done = 1'b1;
			end

			DES_DONE:
			begin
				next_des_done = 1'b1;
			end

			//DES_DONE_2:
			//begin
			//	next_des_done = 1'b1;
			//end

		endcase
	end

endmodule
