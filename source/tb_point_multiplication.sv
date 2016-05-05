// $Id: $
// File name:   tb_point_multiplication.sv
// Created:     3/25/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for Point Multiplication



`timescale 1ns / 100ps
module tb_point_multiplication
(
);

	localparam NUM_BITS = 163;	
	localparam NUM_INPUT_BITS = 3;
	localparam CLK_PERIOD = 4;
	localparam ROLLOVER_VAL = 10;
	localparam NUM_TEST_CASES = 10;
	localparam CHECK_DELAY = 1; // Check 1ns after the rising edge to allow for propagation delay

  	// Declare test bench signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_start;
	reg tb_done;
	reg [NUM_BITS:0]tb_x1;
	reg [NUM_BITS:0]tb_y1;
	reg [NUM_BITS:0]tb_x2;
	reg [NUM_BITS:0]tb_y2;

	//Regs going to be used to show functionality
	reg [NUM_BITS:0]tb_pubAX;
	reg [NUM_BITS:0]tb_pubAY;

	reg [NUM_BITS:0]tb_pubBX;
	reg [NUM_BITS:0]tb_pubBY;

	reg [NUM_BITS:0]tb_sesPubAPrivBX;
	reg [NUM_BITS:0]tb_sesPubAPrivBY;


	reg [NUM_BITS:0]tb_sesPubBPrivAX;
	reg [NUM_BITS:0]tb_sesPubBPrivAY;

	reg [NUM_BITS:0]tb_k;
	integer i;
	integer tb_test_num;

	//Private keys of the 2 users
	logic [NUM_BITS:0] privA = 164'h5;
	logic [NUM_BITS:0] privB = 164'd15;

	//The generator element that will be used by ECC to generate the public key. This value was provided by NIST
	logic [NUM_BITS:0] genX = 164'h3f0eba16286a2d57ea0991168d4994637e8343e36;
	logic [NUM_BITS:0] genY = 164'h0d51fbc6c71a0094fa2cdd545b11c5c0c797324f1;
	
	//The correct session key and public key values got using python
	reg [NUM_BITS:0] correctSesX = 164'h129e4d24d07531e5c99ffad67da9005631c44b61a;
	reg [NUM_BITS:0] correctSesY = 164'h4927babad5319b9941617be017a7ee92a188ce39c;
	reg [NUM_BITS:0] correctPubAX = 164'h092170d7458ced62a775e2f85c1cd70cd63a70c81;
	reg [NUM_BITS:0] correctPubAY = 164'h72294e7900b1cd6f1f8e5766d4217d61884ca79aa;
	reg [NUM_BITS:0] correctPubBX = 164'h0579ee5f7d26ba2fdf3a68c9a0832b0fa52213fd1;
	reg [NUM_BITS:0] correctPubBY = 164'h45814fea6e93d1df4c85e9b4f9f53fa2bd39cc3c3;

	//Clock setup
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	// DUT Port maps
	point_multiplication DUT(.clk(tb_clk), .n_rst(tb_n_rst), .x(tb_x1), .y(tb_y1), .SkX(tb_x2), .SkY(tb_y2),.k(tb_k), .start(tb_start), .done(tb_done));


	// Test bench process
	initial
	begin

		//Initial k value
		tb_k = privA;
	
		//Initial x,y value
		tb_x1 = genX;
		tb_y1 = genY;

		//Initial start value
		tb_start = 0;

		//Initial test number set to 0
		tb_test_num = 0;

		// Power-on Reset of the DUT
		#(0.1);
		tb_n_rst	= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
		#(CLK_PERIOD * 2.25);	// Release the reset away from a clock edge
		tb_n_rst	= 1'b1; 	// Deactivate the chip reset

		// Wait for a while to see normal operation
		#(CLK_PERIOD);

		//Test Case 1 
		//This test case does a whole diffe helman key exchange, starting by calculating the first public key, then the second public key
		//Followed by the 2 session keys, the 2 session keys should be the same
		tb_test_num += 1;

		$info("Test case %d \n", tb_test_num);
		$info("Starting Calculation of A's Public Key");

		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_start = 1;
		@(negedge tb_clk);
		tb_start = 0;

		//Waits till it gets a 1 from tb_done, this will indicate that the first point mult is done
		while(1)
		begin
			@(posedge tb_done);
			#(CHECK_DELAY);

			if (tb_done == 1'b1)
			begin
				$info("A's Public Key Generation Completed");
				break;
			end 
		end
		@(negedge tb_clk);	
		@(negedge tb_clk);	

		//Store the public key values
		tb_pubAX = tb_x2;
		tb_pubAY = tb_y2;

		//Checks if the correct public key value is generated
		if((correctPubAX == tb_pubAX) && (correctPubAY == tb_pubAY))
			$info("Correct Public keys generated for A");
		else
			$error("Incorrect Public keys generated for A");


		//Does the second point mult which does the calculation of B's public key
		$info("Starting Calculation of B's Public Key");
		tb_k = privB;
		@(negedge tb_clk);
		tb_start = 1;
		@(negedge tb_clk);
		tb_start = 0;

		//Waits till it gets a 1 from tb_done, this will indicate that the second point mult is done
		while(1)
		begin
			@(posedge tb_done);
			#(CHECK_DELAY);

			if (tb_done == 1'b1)
			begin
				$info("B's Public Key Generation Completed");
				break;
			end 
		end
		@(negedge tb_clk);	
		@(negedge tb_clk);	

		tb_pubBX = tb_x2;
		tb_pubBY = tb_y2;

		if((correctPubBX == tb_pubBX) && (correctPubBY == tb_pubBY))
			$info("Correct Public keys generated for B");
		else
			$info("Incorrect Public keys generated for B");

		$info("Starting Third mult");
		tb_x1 = tb_pubAX;
		tb_y1 = tb_pubAY;
		@(negedge tb_clk);
		tb_start = 1;
		@(negedge tb_clk);
		tb_start = 0;

		//Waits till it gets a 1 from tb_done, this will indicate that the third point mult is done
		while(1)
		begin
			@(posedge tb_done);
			#(CHECK_DELAY);

			if (tb_done == 1'b1)
			begin
				$info("B's Public Key Generation Completed");
				break;
			end 
		end

		tb_sesPubAPrivBX = tb_x2;
		tb_sesPubAPrivBY = tb_y2;

		$info("Third mult done");
		if((correctSesX == tb_sesPubAPrivBX) && (correctSesY == tb_sesPubAPrivBY))
			$info("Correct Session keys generated by B");
		else
			$info("Incorrect Session keys generated by B");

		@(negedge tb_clk);	
		@(negedge tb_clk);	

		tb_x1 = tb_pubBX;
		tb_y1 = tb_pubBY;
		tb_k = privA;
		
		$info("Starting Fourth mult");
		@(negedge tb_clk);
		tb_start = 1;
		@(negedge tb_clk);
		tb_start = 0;


		//Waits till it gets a 1 from tb_done, this will indicate that the fourth point mult is done
		while(1)
		begin
			@(posedge tb_done);
			#(CHECK_DELAY);

			if (tb_done == 1'b1)
			begin
				$info("B's Public Key Generation Completed");
				break;
			end 
		end

		tb_sesPubBPrivAX = tb_x2;
		tb_sesPubBPrivAY = tb_y2;
		$info("Fourth mult done");

		if((correctSesX == tb_sesPubBPrivAX) && (correctSesY == tb_sesPubBPrivAY))
			$info("Correct Session keys generated by A");
		else
			$info("Incorrect Session keys generated by A");

		@(negedge tb_clk);	
		@(negedge tb_clk);	

		if((correctSesX == tb_sesPubAPrivBX) && (correctSesY == tb_sesPubAPrivBY))
			$info("Correct session keys generated");
		else
			$info("Incorrect session keys generated");

		if((tb_sesPubBPrivAX == tb_sesPubAPrivBX) && (tb_sesPubBPrivAY == tb_sesPubAPrivBY))
		begin
			$info("Session Keys Match for both Parties");
		end
		else
		begin	
			$info("Session Keys do not match");
		end
	end


endmodule