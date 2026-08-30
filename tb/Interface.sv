import pckg::*;
interface intf (
    input bit clk
);

  logic [WIDTH-1:0] data_in;
  logic [WADDR-1:0] address;
  logic enable, rst_n;
  logic [WIDTH-1:0] data_out;
  logic valid_out;

  clocking drv_cb @(posedge clk); //driver's POV 
  default input #1step output #1ns; //skew
  output data_in, address, enable, rst_n; 
  endclocking

  clocking mcb @(posedge clk); //**********************************************
  default input #0; //#0 to sample in OBSERVED REGION AFTER NBA (VIM)
  input data_in, address, enable, rst_n, data_out, valid_out;
  endclocking

  modport drv(clocking drv_cb, input rst_n); 
  modport mon(clocking mcb, input rst_n);
  modport dut(input clk, data_in, address, enable, rst_n, output data_out, valid_out);



  //ASSERTION ON valid out === ~ enable
  property p_valid_out_tracks_not_enable;
  @(posedge clk) disable iff (!rst_n)
    (enable |=> !valid_out) and (!enable |=> valid_out);
  endproperty

  assert property (p_valid_out_tracks_not_enable)
    else $error("[ASSERTION FAILURE] @%0t valid_out=%0b but expected ~enable(prev cycle)=%0b (enable_prev=%0b)",
                $time, valid_out, ~$past(enable), $past(enable));


endinterface
