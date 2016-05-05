module system_fpga (
  ///////// CLOCKS //////////
  input logic  CLOCK_50,
  
  /////////// KEY ///////////
  input logic [3:0] KEY,
  
  //////////// SW ///////////
  input logic [17:0] SW,
  
  /////////// LED ///////////
  output logic [3:0] LEDG,
  output logic [17:0] LEDR,

  /////////// HEX ///////////
  output logic [6:0] HEX0,
  output logic [6:0] HEX1,
  output logic [6:0] HEX2,
  output logic [6:0] HEX3,
  output logic [6:0] HEX4,
  output logic [6:0] HEX5,
  output logic [6:0] HEX6,
  output logic [6:0] HEX7,

  ///////// PCIE ////////////
  input logic PCIE_PERST_N,
  input logic PCIE_REFCLK_P,
  input logic PCIE_RX_P,
  output logic PCIE_TX_P,
  output logic PCIE_WAKE_N,
  
  ////////// FAN ////////////
  inout logic FAN_CTRL
);
  // turn off fan
  assign FAN_CTRL = 1'b0;

  // wake up pcie
  assign PCIE_WAKE_N = 1'b1;
  
  // make board pretty
  assign LEDG[0] = ~KEY[0];
  assign LEDR[17:0] = SW[17:0];
  
  assign HEX7 = 7'b0000110; //E
  assign HEX6 = 7'b1000110; //C
  assign HEX5 = 7'b1000110; //C
  assign HEX4 = 7'b1111111; // 
  assign HEX3 = 7'b0110000; //3
  assign HEX2 = 7'b0100001; //D
  assign HEX1 = 7'b0000110; //E
  assign HEX0 = 7'b0010010; //S

  // avalon bus
  avalon_system u0 (
      .clk_clk                     (CLOCK_50),             //               clk.clk
      .reset_reset_n               (KEY[0]),               //             reset.reset_n
      .pcie_ip_refclk_export       (PCIE_REFCLK_P),        //    pcie_ip_refclk.export
      .pcie_ip_pcie_rstn_export    (PCIE_PERST_N),         // pcie_ip_pcie_rstn.export
      .pcie_ip_rx_in_rx_datain_0   (PCIE_RX_P),            //     pcie_ip_rx_in.rx_datain_0
      .pcie_ip_tx_out_tx_dataout_0 (PCIE_TX_P)             //    pcie_ip_tx_out.tx_dataout_0
  );
  
endmodule