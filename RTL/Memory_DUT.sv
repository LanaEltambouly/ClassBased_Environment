import pckg::*;
module mem_16x32 (
    intf.dut mem_dut
);
  
  logic [WIDTH-1:0] mem[0:DEPTH-1];

  always_ff @(posedge mem_dut.clk or negedge mem_dut.rst_n) begin
    if (!mem_dut.rst_n) begin
      mem_dut.data_out <= 0;
      mem_dut.valid_out <= 0;
    end else if (mem_dut.enable) begin  //write
      mem[mem_dut.address] <= mem_dut.data_in;
      mem_dut.valid_out <= 1'b0;
    end else if(!mem_dut.enable) begin  //read
      mem_dut.data_out <= mem[mem_dut.address];
      mem_dut.valid_out <= 1'b1;
    end
  end

endmodule
