class transaction;
    // randomized 
  rand bit [WIDTH-1:0] data_in;
  rand bit [WADDR-1:0] address;
  rand bit enable;
  rand bit rst_n;
  // non-randomized for monitor and scoreboard to check outputs 
  logic [WIDTH-1:0] data_out;
  logic valid_out;
  // Metadata for debugging
  int id;
  static int count = 0;

  //default constructor overwrite
  function new();
    count++;
    this.id = count;
  endfunction

  //constraints while randomization s
  constraint reset_distribution {
        rst_n dist {0:/10, 1:/90};
    }

  //Deep Copy 
  function transaction copy();
    transaction copy_tx = new();
    copy_tx.data_in = this.data_in;
    copy_tx.address = this.address;
    copy_tx.enable = this.enable;
    copy_tx.data_out = this.data_out;
    copy_tx.valid_out = this.valid_out;
    return copy_tx;
  endfunction

  function void print();
   $display("[TX ID:%0d] EN=%0b ADDR=0x%0h DIN=0x%0h DOUT=0x%0h VALID=%0b", id, enable, address, data_in, data_out, valid_out);
endfunction

endclass
