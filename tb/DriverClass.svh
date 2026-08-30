class driver;
  //virtual interface 
  virtual intf.drv vif;
  mailbox #(transaction) seq2drv_mbx;
  int items = 0;

  function new(virtual intf.drv vif, mailbox#(transaction) seq2drv_mbx);
    this.vif = vif;
    this.seq2drv_mbx = seq2drv_mbx;
  endfunction

  task run();
  transaction tx;
    forever begin
      seq2drv_mbx.get(tx);
      $display("Driver");
      items++;
      // Drive stimulus
      @(vif.drv_cb);
      vif.drv_cb.rst_n <= tx.rst_n;
      vif.drv_cb.address <= tx.address;
      vif.drv_cb.enable  <= tx.enable;
      vif.drv_cb.data_in <= tx.data_in;
    end

  endtask

endclass
