class subscriber; //coverage extractor
  mailbox #(transaction) mon2sub_mbx;
  transaction tx;

  covergroup cg_mem with function sample(transaction tx);

  cp_rst_n: coverpoint tx.rst_n {
    bins zero = {0};
    bins one = {1};
    bins one_zero = (1 => 0);
    bins zero_one = (0 => 1);
    }
  cp_enable: coverpoint tx.enable {
    bins one = {1};
    bins zero = {0};
    bins one_zero = (1 => 0);
    bins zero_one = (0 => 1); 
    }
  cp_valid_out: coverpoint tx.valid_out {
    bins one = {1};
    bins zero = {0};
    }
  cp_address: coverpoint tx.address {
    bins mini = {0};
    bins max = {DEPTH - 1};
    bins inbetween[] = {[1:DEPTH-2]};
  }

  cp_enable_address: cross cp_enable, cp_address;
  endgroup

  function new(mailbox #(transaction) mon2sub_mbx);
  this.mon2sub_mbx = mon2sub_mbx;
  cg_mem = new();
  endfunction
  
  task run();
  forever begin
    mon2sub_mbx.get(tx);
    cg_mem.sample(tx);  
  end
  endtask

endclass
