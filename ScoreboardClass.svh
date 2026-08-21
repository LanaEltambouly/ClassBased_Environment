import pckg::WIDTH;
class scoreboard;
  mailbox #(transaction) mon2scb_mbx;
  //Golden Reference: associative array 
  logic [WIDTH-1:0] ref_mem[int];
  transaction reads[$]; //queue to store previous tx reads because that monitor samples in preponed region then driver drives in NBA then output affects scorboard in the upcoming cycle 

  function new(mailbox#(transaction) mon2scb_mbx);
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  int error_count  = 0;
  int pass_count = 0;

  task run();
  transaction tx;
  transaction prv_tx;
  
  forever begin
    mon2scb_mbx.get(tx);

    if (!tx.rst_n) begin
      reads.delete();
      continue; 
    end

    // 1. Process output of PREVIOUS read request (1-cycle read latency)
    if (reads.size() > 0) begin
      prv_tx = reads.pop_front();
  
      if (ref_mem.exists(prv_tx.address)) begin
        if (tx.valid_out !== 1'b1) begin
          error_count++;
          $error("[%0t] [SCB ERROR] valid_out not asserted for Read! Addr=0x%0h", $time, prv_tx.address);
        end else if (tx.data_out !== ref_mem[prv_tx.address]) begin
          error_count++;
          $error("[%0t] [SCB ERROR] Data Mismatch! Addr=0x%0h | Exp=0x%0h | Act=0x%0h", 
                 $time, prv_tx.address, ref_mem[prv_tx.address], tx.data_out);
        end else begin
          pass_count++;
          $display("[%0t] [SCB PASS] Addr=0x%0h | Exp=0x%0h | Act=0x%0h", 
                   $time, prv_tx.address, ref_mem[prv_tx.address], tx.data_out);
        end
      end else begin
        // Unwritten address read warning (does not increment error_count)
        $warning("[%0t] [SCB WARN] Read from unwritten address 0x%0h | Act=0x%0h", 
                 $time, prv_tx.address, tx.data_out);
      end
    end 

    // 2. Process CURRENT transaction driven on interface
    if (tx.enable) begin
      // Write transaction: Update reference memory
      ref_mem[tx.address] = tx.data_in;
      $display("[%0t] [SCB WRITE] Addr=0x%0h <= Data=0x%0h", $time, tx.address, tx.data_in);
      pass_count++;
    end else begin
      // Read transaction: Queue for evaluation in next cycle
      reads.push_back(tx);
      $display("[%0t] [SCB READ REQ] Addr=0x%0h Queued", $time, tx.address);
    end     
  end 
endtask

  function void report();
    $display("\n==================================================");
    $display("               SCOREBOARD SUMMARY                 ");
    $display("==================================================");
    $display(" Passes : %0d", pass_count);
    $display(" Errors  : %0d", error_count);
    $display("==================================================");
  endfunction

endclass


