// File name : ECCDH3DES_fpga.sv
// Author : Xiongyao Zha, Manish Gupta
// Created : 03/29/2015
// Version 1.0 
// Description : FPGA wrapper for ECCDH3DES chip on the Avalon Bus.

module ECCDH3DES_fpga #(
    parameter SLAVE_ADDRESSWIDTH = 8 ,      // ADDRESSWIDTH specifies how many addresses the slave needs to be mapped to. log(NUMREGS)
    parameter DATAWIDTH = 32,               // DATAWIDTH specifies the data width. Default 32 bits
    parameter NUMREGS = 256,                // Number of Internal Registers for Custom Logic
    parameter REGWIDTH = 32,                // Data Width for the Internal Registers. Default 32 bits
    parameter ADDRSIZE = 14,                // Default SRAM address width.
    parameter SRAMWIDTH = 64                // Default SRAM data width.
)  
(   
    input logic  clk,
    input logic  reset_n,
    
    // Bus Slave Interface
    input logic [SLAVE_ADDRESSWIDTH-1:0] slave_address,
    input logic  slave_chipselect,
    input logic  slave_write,
    input logic [DATAWIDTH-1:0] slave_writedata,
    input logic  slave_read,
    output logic [DATAWIDTH-1:0] slave_readdata
);

typedef enum {IDLE, WRITE_INPUT, READ_OUTPUT } state_t;
state_t state, next_state;

// ECC
logic [163:0] PuX;
logic [163:0] PuY;

logic data_valid_out, data_valid_in, next_data_valid_in;

logic next_ecc1_done;
logic next_ecc2_done;
logic next_des_done;

logic [SRAMWIDTH-1:0] input_data1;
logic [ADDRSIZE-1:0] sram_Addr1;
logic sramRE1;
logic sramWE1;
logic [SRAMWIDTH-1:0] output_data1;

logic [SRAMWIDTH-1:0] next_input_data1;
logic [ADDRSIZE-1:0] next_sram_Addr1;
logic next_sramRE1;
logic next_sramWE1;
logic [SRAMWIDTH-1:0] next_output_data1;

logic [SRAMWIDTH-1:0] input_data2;
logic [ADDRSIZE-1:0] sram_Addr2;
logic sramRE2;
logic sramWE2;
logic [SRAMWIDTH-1:0] output_data2;

logic [SRAMWIDTH-1:0] next_input_data2;
logic [ADDRSIZE-1:0] next_sram_Addr2;
logic next_sramRE2;
logic next_sramWE2;
logic [SRAMWIDTH-1:0] next_output_data2;

logic write_sram_start;

logic des_done;

logic read_flag_1;
logic read_flag_2;
logic next_read_flag_1;
logic next_read_flag_2;

logic [63:0] next_actual_data;
logic [63:0] actual_data;
logic [63:0] encrypted_data;

// CONSTANTS
parameter START_BYTE = 32'hF00BF00B;
parameter STOP_BYTE = 32'hDEADF00B;
parameter SRAM_ADDR = 32'h1;
parameter SRAM_ADDR2 = 32'h1;

// Command and Status Registers (CSR) for custom logic
logic [NUMREGS-1:0][REGWIDTH-1:0] csr_registers; 

// SRAM VARIABLES
assign write_sram_start = csr_registers[35][0];

// Slave side 
always_ff @ ( posedge clk ) begin 
  if(!reset_n)
    begin
        slave_readdata <= 32'h0;
        csr_registers <= '0;

        state <= IDLE;

        sram_Addr1 <= SRAM_ADDR;
        input_data1 <= '0;
        sramWE1 <= 1'b0;
        sramRE1 <= 1'b0;

        sram_Addr2 <= SRAM_ADDR2;
        input_data2 <= '0;
        sramWE2 <= 1'b0;
        sramRE2 <= 1'b0;

        data_valid_in <= 1'b0;

        actual_data <= '0;

        read_flag_1 <= 1'b0;
        read_flag_2 <= 1'b0;


    end else begin

        csr_registers[0][31] <= next_ecc1_done;
        csr_registers[0][25] <= next_ecc2_done;

        // des done signal
        csr_registers[0][24] <= (csr_registers[41] == sram_Addr2);

        // copy public keys
        if(csr_registers[0][31])
        begin
            csr_registers[26]        <= PuY[163:132];
            csr_registers[27]        <= PuY[131:100];
            csr_registers[28]        <= PuY[99:68];
            csr_registers[29]        <= PuY[67:36];
            csr_registers[30]        <= PuY[35:4];
            csr_registers[31][31:28] <= PuY[3:0];

            csr_registers[20]        <= PuX[163:132];
            csr_registers[21]        <= PuX[131:100];
            csr_registers[22]        <= PuX[99:68];
            csr_registers[23]        <= PuX[67:36];
            csr_registers[24]        <= PuX[35:4];
            csr_registers[25][31:28] <= PuX[3:0];
        end

        // state transition
        state <= next_state;

        // update sram1
        sram_Addr1  <= next_sram_Addr1;
        input_data1 <= next_input_data1;
        sramWE1     <= next_sramWE1;
        sramRE1     <= next_sramRE1;

        // update sram2
        sram_Addr2  <= next_sram_Addr2;
        input_data2 <= next_input_data2;
        sramWE2     <= next_sramWE2;
        sramRE2     <= next_sramRE2;

        actual_data <= next_actual_data;
        data_valid_in <= next_data_valid_in;

        read_flag_1 <= next_read_flag_1;
        read_flag_2 <= next_read_flag_2;

        // debug registers
        csr_registers[50] <= {18'b0, sram_Addr1};
        csr_registers[51] <= {18'b0, sram_Addr2};
        csr_registers[52] <= encrypted_data[63:32]; 
        csr_registers[53] <= encrypted_data[31: 0];

        // state for srams
        if (state == IDLE)
        begin
            csr_registers[35][31] <= 1'b0;
            csr_registers[38][0]  <= 1'b0;
            csr_registers[38][31] <= 1'b0;
        end

        else if (state == WRITE_INPUT)
        begin
            csr_registers[35][31] <= 1'b1; // written into SRAM
            csr_registers[38][0]  <= 1'b0;
            csr_registers[38][31] <= 1'b0;
        end

        else if (state == READ_OUTPUT)
        begin
            csr_registers[35][31] <= 1'b0;
            csr_registers[38][0]  <= 1'b1; // read from SRAM
            csr_registers[38][31] <= 1'b0;

            csr_registers[40] <= output_data2[63:32];
            csr_registers[39] <= output_data2[31: 0];
        end

        // READ/WRITE
        if(slave_write && slave_chipselect && (slave_address >= 0) && (slave_address < NUMREGS))
        begin
           csr_registers[slave_address] <= slave_writedata;  // Write a value to a CSR register
        end
        else if(slave_read && slave_chipselect  && (slave_address >= 0) && (slave_address < NUMREGS)) // reading a CSR Register
        begin
            slave_readdata <= csr_registers[slave_address];
        end
    end
end


// Next State Logic
always_comb 
begin : STATE_TRANSITION
    next_state = state;

    next_sram_Addr1  = sram_Addr1;
    next_input_data1 = input_data1;
    next_sramWE1     = 1'b0;
    next_sramRE1     = 1'b0;

    next_sram_Addr2  = sram_Addr2;
    next_input_data2 = input_data2;
    next_sramWE2     = 1'b0;
    next_sramRE2     = 1'b0;
    
    next_actual_data = actual_data;

    next_data_valid_in = 1'b0;

    next_read_flag_1 = 1'b0;
    next_read_flag_2 = 1'b0;

    case(state)
        IDLE:
        begin
            if ( write_sram_start )
            begin
                next_state = WRITE_INPUT;
                next_input_data1 = {csr_registers[37], csr_registers[36]};
                next_sramWE1 = 1'b1;
            end
            else if ( csr_registers[45][31] )
            begin
                next_state = READ_OUTPUT;
                next_sram_Addr2 = sram_Addr2 - 1;
                next_sramRE2 = 1'b1;
            end
            else 
            begin
                next_state = IDLE;
            end
        end

        WRITE_INPUT:
        begin
            if ( write_sram_start )
            begin
                next_state = WRITE_INPUT;
            end
            else
            begin
                next_sram_Addr1 = sram_Addr1 + 1;
                next_state = IDLE;
            end
        end

        READ_OUTPUT:
        begin
            if ( csr_registers[38][31] )
            begin
                next_state = IDLE;
            end
            else
            begin
                next_state = READ_OUTPUT;
                next_sramRE2 = 1'b1;
            end
        end
    endcase

    if ( csr_registers[0][2] && sram_Addr1 > SRAM_ADDR )
    begin
        next_sram_Addr1 = sram_Addr1 - 1;
        next_sramRE1 = 1'b1;
    end

    if ( sramRE1 )
    begin
        next_read_flag_1 = 1'b1;
    end

    if ( read_flag_1 )
    begin
        next_read_flag_2 = 1'b1;
    end

    if ( read_flag_2 )
    begin
        next_actual_data = output_data1;
        next_data_valid_in = 1'b1;
    end

    if ( data_valid_out )
    begin
        next_input_data2 = encrypted_data;
        next_sramWE2 = 1'b1;
    end

    if ( sramWE2 )
    begin
        next_sram_Addr2 = sram_Addr2 + 1;
    end

end

// DUT
ECCDH3DES ECC
(
    .clk(clk),
    .n_rst(reset_n),

    // INPUT
    .raw_data(actual_data),
    .encrypted_data(encrypted_data),
    .PX({csr_registers[13], csr_registers[14], csr_registers[15], csr_registers[16], csr_registers[17], csr_registers[18][31:28]}),
    .PY({csr_registers[7], csr_registers[8], csr_registers[9], csr_registers[10], csr_registers[11], csr_registers[12][31:28]}),
    .k({csr_registers[1], csr_registers[2], csr_registers[3], csr_registers[4], csr_registers[5], csr_registers[6][31:28]}),
    .ecc1_start(csr_registers[0][0]),
    .ecc2_start(csr_registers[0][1]),
    .des_start(csr_registers[0][2] && (sram_Addr1 > SRAM_ADDR)),
    .is_encrypt(csr_registers[0][3]),

    // OUTPUT
    .ecc1_done(next_ecc1_done),
    .ecc2_done(next_ecc2_done),
    .des_done(next_des_done),
    
    .data_valid_in(data_valid_in),
    .data_valid_out(data_valid_out),
    .PuX(PuX),
    .PuY(PuY)
);

sram sram_inst1 (
    .clock ( clk ),
    .data ( input_data1 ),
    .address ( sram_Addr1 ),
    .rden ( sramRE1 ),
    .wren ( sramWE1 ),
    .q ( output_data1 )
);

sram sram_inst2 (
    .clock ( clk ),
    .data ( input_data2 ),
    .address ( sram_Addr2 ),
    .rden ( sramRE2 ),
    .wren ( sramWE2 ),
    .q ( output_data2 )
);

endmodule 
