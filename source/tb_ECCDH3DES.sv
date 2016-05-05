// $Id: $
// File name:   tb_ECCDH3DES.sv
// Created:     4/28/2015
// Author:      Manish Gupta
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for the top level file for ECCDH3DES

`timescale 1ns / 100ps
module tb_ECCDH3DES
(
);

	localparam NUM_BITS = 163;	
	localparam NUM_INPUT_BITS = 3;
	localparam CLK_PERIOD = 4;
	localparam ROLLOVER_VAL = 10;
	localparam CHECK_DELAY = 1; // Check 1ns after the rising edge to allow for propagation delay


	parameter KEY_FILE 			= "./pythond3s/192bitkey.txt";
	parameter NUM_TEST_CASES    = 100;
	string IN_FILES [100] 		= {"./pythond3s/inputblock_0.txt", "./pythond3s/inputblock_1.txt", "./pythond3s/inputblock_2.txt", "./pythond3s/inputblock_3.txt", "./pythond3s/inputblock_4.txt", "./pythond3s/inputblock_5.txt", "./pythond3s/inputblock_6.txt", "./pythond3s/inputblock_7.txt", "./pythond3s/inputblock_8.txt", "./pythond3s/inputblock_9.txt", "./pythond3s/inputblock_10.txt", "./pythond3s/inputblock_11.txt", "./pythond3s/inputblock_12.txt", "./pythond3s/inputblock_13.txt", "./pythond3s/inputblock_14.txt", "./pythond3s/inputblock_15.txt", "./pythond3s/inputblock_16.txt", "./pythond3s/inputblock_17.txt", "./pythond3s/inputblock_18.txt", "./pythond3s/inputblock_19.txt", "./pythond3s/inputblock_20.txt", "./pythond3s/inputblock_21.txt", "./pythond3s/inputblock_22.txt", "./pythond3s/inputblock_23.txt", "./pythond3s/inputblock_24.txt", "./pythond3s/inputblock_25.txt", "./pythond3s/inputblock_26.txt", "./pythond3s/inputblock_27.txt", "./pythond3s/inputblock_28.txt", "./pythond3s/inputblock_29.txt", "./pythond3s/inputblock_30.txt", "./pythond3s/inputblock_31.txt", "./pythond3s/inputblock_32.txt", "./pythond3s/inputblock_33.txt", "./pythond3s/inputblock_34.txt", "./pythond3s/inputblock_35.txt", "./pythond3s/inputblock_36.txt", "./pythond3s/inputblock_37.txt", "./pythond3s/inputblock_38.txt", "./pythond3s/inputblock_39.txt", "./pythond3s/inputblock_40.txt", "./pythond3s/inputblock_41.txt", "./pythond3s/inputblock_42.txt", "./pythond3s/inputblock_43.txt", "./pythond3s/inputblock_44.txt", "./pythond3s/inputblock_45.txt", "./pythond3s/inputblock_46.txt", "./pythond3s/inputblock_47.txt", "./pythond3s/inputblock_48.txt", "./pythond3s/inputblock_49.txt", "./pythond3s/inputblock_50.txt", "./pythond3s/inputblock_51.txt", "./pythond3s/inputblock_52.txt", "./pythond3s/inputblock_53.txt", "./pythond3s/inputblock_54.txt", "./pythond3s/inputblock_55.txt", "./pythond3s/inputblock_56.txt", "./pythond3s/inputblock_57.txt", "./pythond3s/inputblock_58.txt", "./pythond3s/inputblock_59.txt", "./pythond3s/inputblock_60.txt", "./pythond3s/inputblock_61.txt", "./pythond3s/inputblock_62.txt", "./pythond3s/inputblock_63.txt", "./pythond3s/inputblock_64.txt", "./pythond3s/inputblock_65.txt", "./pythond3s/inputblock_66.txt", "./pythond3s/inputblock_67.txt", "./pythond3s/inputblock_68.txt", "./pythond3s/inputblock_69.txt", "./pythond3s/inputblock_70.txt", "./pythond3s/inputblock_71.txt", "./pythond3s/inputblock_72.txt", "./pythond3s/inputblock_73.txt", "./pythond3s/inputblock_74.txt", "./pythond3s/inputblock_75.txt", "./pythond3s/inputblock_76.txt", "./pythond3s/inputblock_77.txt", "./pythond3s/inputblock_78.txt", "./pythond3s/inputblock_79.txt", "./pythond3s/inputblock_80.txt", "./pythond3s/inputblock_81.txt", "./pythond3s/inputblock_82.txt", "./pythond3s/inputblock_83.txt", "./pythond3s/inputblock_84.txt", "./pythond3s/inputblock_85.txt", "./pythond3s/inputblock_86.txt", "./pythond3s/inputblock_87.txt", "./pythond3s/inputblock_88.txt", "./pythond3s/inputblock_89.txt", "./pythond3s/inputblock_90.txt", "./pythond3s/inputblock_91.txt", "./pythond3s/inputblock_92.txt", "./pythond3s/inputblock_93.txt", "./pythond3s/inputblock_94.txt", "./pythond3s/inputblock_95.txt", "./pythond3s/inputblock_96.txt", "./pythond3s/inputblock_97.txt", "./pythond3s/inputblock_98.txt", "./pythond3s/inputblock_99.txt"};	
	string OUT_FILES [100] 		= {"./pythond3s/outputofdes_0.txt", "./pythond3s/outputofdes_1.txt", "./pythond3s/outputofdes_2.txt", "./pythond3s/outputofdes_3.txt", "./pythond3s/outputofdes_4.txt", "./pythond3s/outputofdes_5.txt", "./pythond3s/outputofdes_6.txt", "./pythond3s/outputofdes_7.txt", "./pythond3s/outputofdes_8.txt", "./pythond3s/outputofdes_9.txt", "./pythond3s/outputofdes_10.txt", "./pythond3s/outputofdes_11.txt", "./pythond3s/outputofdes_12.txt", "./pythond3s/outputofdes_13.txt", "./pythond3s/outputofdes_14.txt", "./pythond3s/outputofdes_15.txt", "./pythond3s/outputofdes_16.txt", "./pythond3s/outputofdes_17.txt", "./pythond3s/outputofdes_18.txt", "./pythond3s/outputofdes_19.txt", "./pythond3s/outputofdes_20.txt", "./pythond3s/outputofdes_21.txt", "./pythond3s/outputofdes_22.txt", "./pythond3s/outputofdes_23.txt", "./pythond3s/outputofdes_24.txt", "./pythond3s/outputofdes_25.txt", "./pythond3s/outputofdes_26.txt", "./pythond3s/outputofdes_27.txt", "./pythond3s/outputofdes_28.txt", "./pythond3s/outputofdes_29.txt", "./pythond3s/outputofdes_30.txt", "./pythond3s/outputofdes_31.txt", "./pythond3s/outputofdes_32.txt", "./pythond3s/outputofdes_33.txt", "./pythond3s/outputofdes_34.txt", "./pythond3s/outputofdes_35.txt", "./pythond3s/outputofdes_36.txt", "./pythond3s/outputofdes_37.txt", "./pythond3s/outputofdes_38.txt", "./pythond3s/outputofdes_39.txt", "./pythond3s/outputofdes_40.txt", "./pythond3s/outputofdes_41.txt", "./pythond3s/outputofdes_42.txt", "./pythond3s/outputofdes_43.txt", "./pythond3s/outputofdes_44.txt", "./pythond3s/outputofdes_45.txt", "./pythond3s/outputofdes_46.txt", "./pythond3s/outputofdes_47.txt", "./pythond3s/outputofdes_48.txt", "./pythond3s/outputofdes_49.txt", "./pythond3s/outputofdes_50.txt", "./pythond3s/outputofdes_51.txt", "./pythond3s/outputofdes_52.txt", "./pythond3s/outputofdes_53.txt", "./pythond3s/outputofdes_54.txt", "./pythond3s/outputofdes_55.txt", "./pythond3s/outputofdes_56.txt", "./pythond3s/outputofdes_57.txt", "./pythond3s/outputofdes_58.txt", "./pythond3s/outputofdes_59.txt", "./pythond3s/outputofdes_60.txt", "./pythond3s/outputofdes_61.txt", "./pythond3s/outputofdes_62.txt", "./pythond3s/outputofdes_63.txt", "./pythond3s/outputofdes_64.txt", "./pythond3s/outputofdes_65.txt", "./pythond3s/outputofdes_66.txt", "./pythond3s/outputofdes_67.txt", "./pythond3s/outputofdes_68.txt", "./pythond3s/outputofdes_69.txt", "./pythond3s/outputofdes_70.txt", "./pythond3s/outputofdes_71.txt", "./pythond3s/outputofdes_72.txt", "./pythond3s/outputofdes_73.txt", "./pythond3s/outputofdes_74.txt", "./pythond3s/outputofdes_75.txt", "./pythond3s/outputofdes_76.txt", "./pythond3s/outputofdes_77.txt", "./pythond3s/outputofdes_78.txt", "./pythond3s/outputofdes_79.txt", "./pythond3s/outputofdes_80.txt", "./pythond3s/outputofdes_81.txt", "./pythond3s/outputofdes_82.txt", "./pythond3s/outputofdes_83.txt", "./pythond3s/outputofdes_84.txt", "./pythond3s/outputofdes_85.txt", "./pythond3s/outputofdes_86.txt", "./pythond3s/outputofdes_87.txt", "./pythond3s/outputofdes_88.txt", "./pythond3s/outputofdes_89.txt", "./pythond3s/outputofdes_90.txt", "./pythond3s/outputofdes_91.txt", "./pythond3s/outputofdes_92.txt", "./pythond3s/outputofdes_93.txt", "./pythond3s/outputofdes_94.txt", "./pythond3s/outputofdes_95.txt", "./pythond3s/outputofdes_96.txt", "./pythond3s/outputofdes_97.txt", "./pythond3s/outputofdes_98.txt", "./pythond3s/outputofdes_99.txt"};	
	integer j;
	integer key_f;
	integer out_f;
	integer in_block_f;

	integer current_test_case_index;
	integer verified_output_index = 0;

	// Declare test bench signals
	reg [0:63] tb_actual_input;
	reg [0:63] tb_actual_output;
	reg [0:NUM_TEST_CASES][0:7][7:0] tb_input_block;
	reg [0:NUM_TEST_CASES][0:7][7:0] tb_ciphertext_block;
	//reg [0:NUM_TEST_CASES][0:7][7:0] tb_output_block;
	reg [0:NUM_TEST_CASES][0:7][7:0] tb_gold_ciphertext_3;


  	// Declare test bench signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_start;
	reg tb_done;
	logic tb_is_encrypt;

	//Regs going to be used to show functionality
	reg [63:0] tb_raw_data, tb_encrypted_data;
	reg tb_data_valid_in, tb_data_valid_out;
	reg tb_ecc1_start, tb_ecc2_start, tb_des_start, tb_ecc1_done, tb_ecc2_done, tb_des_done; 
	logic [NUM_BITS:0] tb_PX, tb_PY, tb_PuX, tb_PuY;
	logic [NUM_BITS:0]tb_k;

	integer i;
	integer tb_test_num;


	//Regs going to be used to show functionality
	reg [NUM_BITS:0]tb_pubAX;
	reg [NUM_BITS:0]tb_pubAY;

	reg [NUM_BITS:0]tb_pubBX;
	reg [NUM_BITS:0]tb_pubBY;

	reg [NUM_BITS:0]tb_sesPubAPrivBX;
	reg [NUM_BITS:0]tb_sesPubAPrivBY;


	reg [NUM_BITS:0]tb_sesPubBPrivAX;
	reg [NUM_BITS:0]tb_sesPubBPrivAY;

	//Private keys of the 2 users
	logic [NUM_BITS:0] privA = 164'h5;
	logic [NUM_BITS:0] privB = 164'd15;

	//The generator element that will be used by ECC to generate the public key. This value was provided by NIST
	logic [NUM_BITS:0]genX = 164'h3f0eba16286a2d57ea0991168d4994637e8343e36;
	logic [NUM_BITS:0]genY = 165'h0d51fbc6c71a0094fa2cdd545b11c5c0c797324f1;
	
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
	ECCDH3DES	DUT(
	 	.clk(tb_clk),
	 	.n_rst(tb_n_rst),

		//DES
	 	.raw_data      (tb_raw_data),
	 	.data_valid_in (tb_data_valid_in),
	 	.data_valid_out(tb_data_valid_out),
	 	.encrypted_data(tb_actual_output),
	 	.is_encrypt(tb_is_encrypt),

		//CONT
		.ecc1_start    (tb_ecc1_start),
		.ecc2_start    (tb_ecc2_start),
		.des_start     (tb_des_start),

		.ecc1_done     (tb_ecc1_done),
		.ecc2_done     (tb_ecc2_done),
		.des_done      (tb_des_done),

		.PuX           (tb_PuX),
		.PuY           (tb_PuY),

		//ECC
		.PX            (tb_PX),
		.PY            (tb_PY),
		.k             (tb_k)
	);



	task input_data;
		input [0:63] data;
	begin
		@(negedge tb_clk);
		tb_raw_data = data;
		tb_data_valid_in = 1;
		@(posedge tb_clk);
		#(1);
		tb_data_valid_in = 0;
		current_test_case_index++;
	end
	endtask

	always @ (negedge tb_clk)
	begin
		if (tb_data_valid_out == 1)
		begin
			assert(tb_actual_output == tb_gold_ciphertext_3[verified_output_index])
			begin
				$info("Everything looks good!");
			end
			else
			begin
				$error("UT OH! STUFF DOESNT LOOK RIGHT! ERRORROROROR!!!");
			end

			verified_output_index++;
		end
	end



	// Test bench process
	initial
	begin
		tb_is_encrypt = 1;

		current_test_case_index = 0;
		for (j=0; j<NUM_TEST_CASES; j++)
		begin

			in_block_f = $fopen(IN_FILES[j], "rb");
			out_f = $fopen(OUT_FILES[j], "rb");


			for (i=0; i<8; i++)
			begin
				$fscanf(out_f,"%c",tb_gold_ciphertext_3[j][i]);
				$fscanf(in_block_f,"%c",tb_input_block[j][i]);
			end

			$fclose(in_block_f);
			$fclose(out_f);

	    end

		//Initial k value
		tb_k = privA;
	
		//Initial x,y value
		tb_PX = genX;
		tb_PY = genY;

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
		tb_ecc1_start = 1;
		@(negedge tb_clk);
		tb_ecc1_start = 0;

		//Waits till it gets a 1 from tb_done, this will indicate that the first point mult is done
		while(1)
		begin
			@(posedge tb_ecc1_done);
			#(CHECK_DELAY);

			if (tb_ecc1_done == 1'b1)
			begin
				$info("A's Public Key Generation Completed");
				break;
			end 
		end
		@(negedge tb_clk);	
		@(negedge tb_clk);	

		//Store the public key values
		tb_pubAX = tb_PuX;
		tb_pubAY = tb_PuY;

		//Checks if the correct public key value is generated
		if((correctPubAX == tb_pubAX) && (correctPubAY == tb_pubAY))
			$info("Correct Public keys generated for A");
		else
			$error("Incorrect Public keys generated for A");


		//Does the second point mult which does the calculation of B's public key
		$info("Starting Calculation of B's Public Key");
		tb_k = privB;
		@(negedge tb_clk);
		tb_ecc1_start = 1;
		@(negedge tb_clk);
		tb_ecc1_start = 0;

		//Waits till it gets a 1 from tb_done, this will indicate that the second point mult is done
		while(1)
		begin
			@(posedge tb_ecc1_done);
			#(CHECK_DELAY);

			if (tb_ecc1_done == 1'b1)
			begin
				$info("B's Public Key Generation Completed");
				break;
			end 
		end
		@(negedge tb_clk);	
		@(negedge tb_clk);	

		tb_pubBX = tb_PuX;
		tb_pubBY = tb_PuY;

		if((correctPubBX == tb_pubBX) && (correctPubBY == tb_pubBY))
			$info("Correct Public keys generated for B");
		else
			$info("Incorrect Public keys generated for B");

		$info("Starting Third mult");

		tb_PX = tb_pubAX;
		tb_PY = tb_pubAY;
		@(negedge tb_clk);
		tb_ecc2_start = 1;
		@(negedge tb_clk);
		tb_ecc2_start = 0;

		//Waits till it gets a 1 from tb_done, this will indicate that the third point mult is done
		while(1)
		begin
			@(posedge tb_ecc2_done);
			#(CHECK_DELAY);

			if (tb_ecc2_done == 1'b1)
			begin
				$info("Session Key using Public Key of A and Private Key of B completed");
				break;
			end 
		end
		@(negedge tb_clk);
		@(negedge tb_clk);	


		tb_sesPubAPrivBX = tb_PuX;
		tb_sesPubAPrivBY = tb_PuY;
		tb_des_start = 1;
	

		for (i=0; i<20; i++)
		begin
			input_data(tb_input_block[current_test_case_index]);
	    end


	    //DONE With DES 
		@(negedge tb_clk);
		tb_des_start = 0;
		@(negedge tb_clk);
		while(1)
		begin
			@(posedge tb_des_done);
			#(CHECK_DELAY);

			if (tb_des_done == 1'b1)
			begin
				$info("DES DONE!!!!!");
				break;
			end 
		end	
	end


endmodule