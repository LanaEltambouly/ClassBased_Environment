import pckg::*;

module top;
  bit clk;

  initial begin
    forever #5 clk = ~clk;
    end 

  intf intr (clk);
  mem_16x32 mem_dut (intr.dut);

  environment env;
  //scenarios to be run
  reset_seq rst_seq;
  write_before_read_seq wbr_seq;
  boundary_seq bnd_seq;
  toggle_seq tgl_seq;
  sweep_seq swp_seq;

  initial begin
    env = new(intr); //virtual interface points to our concrete one
    env.run();

    rst_seq = new(env.seq);
    wbr_seq = new(env.seq);
    bnd_seq = new(env.seq);
    tgl_seq = new(env.seq);
    swp_seq = new(env.seq);
    
    rst_seq.run();
    wbr_seq.run();
    bnd_seq.run();
    tgl_seq.run();
    swp_seq.run();

    env.waitttt();
    env.scb.report();
    $finish;
  end
  endmodule 