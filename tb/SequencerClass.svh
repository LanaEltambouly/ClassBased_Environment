class sequencer;
  //a queue of transactions (IPC) between seq and drv 
  mailbox #(transaction) seq2drv_mbx;
  int loop_count;  //for number of tx and scenarios to be in the queue
  int tx_count;
  function new(mailbox #(transaction) seq2drv_mbx, int loop_count = 10);
    this.seq2drv_mbx = seq2drv_mbx;
    this.loop_count  = loop_count;
    tx_count = 0;
  endfunction
endclass
