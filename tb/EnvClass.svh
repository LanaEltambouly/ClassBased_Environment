class environment;  //env between all classes  

  sequencer seq;
  driver drv;
  monitor mon;
  scoreboard scb;

  virtual intf vif;

  mailbox #(transaction) seq2drv_mbx;
  mailbox #(transaction) mon2scb_mbx;
  mailbox #(transaction) mon2sub_mbx;

  function new(virtual intf vif);
    this.vif = vif;
    //wrap them up
    seq2drv_mbx = new();
    mon2scb_mbx = new();
    mon2sub_mbx = new();
    seq = new(seq2drv_mbx, 100);
    drv = new(vif, seq2drv_mbx);
    mon = new(vif, mon2scb_mbx, mon2sub_mbx);
    scb = new(mon2scb_mbx);
  endfunction

  task run();
    fork
      //seq.run();
      drv.run();
      mon.run();
      scb.run();
    join_none
  endtask

  task waitttt();
    wait(drv.items != 0 && seq.tx_count == drv.items);
    repeat(2) @(vif.mcb);
    //disable fork;
  endtask

endclass
