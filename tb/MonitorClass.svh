class monitor;

  virtual intf.mon vif;
  mailbox #(transaction) mon2scb_mbx;
  mailbox #(transaction) mon2sub_mbx;
  
  event tr_ready;

  function new(virtual intf.mon vif, mailbox#(transaction) mon2scb_mbx,
               mailbox#(transaction) mon2sub_mbx);
    this.vif         = vif;
    this.mon2scb_mbx = mon2scb_mbx;
    this.mon2sub_mbx = mon2sub_mbx;
  endfunction

  task run();
  transaction tx;
    forever begin
      @(vif.mcb);

      tx = new();
      $display("Monitor");
      
      tx.rst_n <= vif.mcb.rst_n;
      tx.enable    <= vif.mcb.enable;
      tx.address   <= vif.mcb.address;
      tx.data_in   <= vif.mcb.data_in;
      tx.data_out  <= vif.mcb.data_out;
      tx.valid_out <= vif.mcb.valid_out;

       ->> tr_ready; // non-blocking event scheduled to fire at NBA

            @tr_ready;

      mon2scb_mbx.put(tx); //As producer-consumer communication 
      mon2sub_mbx.put(tx.copy());

    end
  endtask

endclass
