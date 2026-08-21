virtual class base_sequence; // Enforces that every child class implements its own body task
  sequencer seqr;
  function new(sequencer seqr);
    this.seqr = seqr;
  endfunction
  pure virtual task run();  // Enforces that every child class implements its own body task
endclass

// Implementing our testcases in Verification Plan:

// 1. Reset Sequence
class reset_seq extends base_sequence;

  function new(sequencer seqr);
    super.new(seqr);
  endfunction

  virtual task run();
    transaction tx;

    // Assert Reset
    tx = new();
    if (!tx.randomize() with { rst_n == 1'b0; enable == 1'b0; address == '0; data_in == '0; }) begin
      $fatal(1, "[Reset Seq] Assert randomization failed!");
    end
    tx.print();
    seqr.seq2drv_mbx.put(tx);
    seqr.tx_count++;

    // Deassert Reset
    tx = new();
    if (!tx.randomize() with { rst_n == 1'b1; enable == 1'b0; address == '0; data_in == '0; }) begin
      $fatal(1, "[Reset Seq] Deassert randomization failed!");
    end
    tx.print();
    seqr.seq2drv_mbx.put(tx);
    seqr.tx_count++;
  endtask
endclass


// 2. Write Before Read Sequence
class write_before_read_seq extends base_sequence;

  function new(sequencer seqr);
    super.new(seqr);
  endfunction

  virtual task run();
    repeat (seqr.loop_count) begin
      transaction tx_write = new();
      transaction tx_read  = new();

      // Write Step
      if (!tx_write.randomize() with { enable == 1'b1; rst_n == 1'b1; }) begin
        $fatal(1, "[RAW Seq] Write randomization failed!");
      end
      tx_write.print();
      seqr.seq2drv_mbx.put(tx_write);
      seqr.tx_count++;

      // Read Step (Same address)
      if (!tx_read.randomize() with { enable == 1'b0; rst_n == 1'b1; address == tx_write.address; }) begin
        $fatal(1, "[RAW Seq] Read randomization failed!");
      end
      tx_read.print();
      seqr.seq2drv_mbx.put(tx_read);
      seqr.tx_count++;
    end
  endtask
endclass


// 3. Boundary Access Sequence
class boundary_seq extends base_sequence;

  function new(sequencer seqr);
    super.new(seqr);
  endfunction

  virtual task run();
    transaction tx;

    // Lower Boundary (0x0)
    tx = new();
    if (!tx.randomize() with { enable == 1'b1; rst_n == 1'b1; address == 4'h0; }) begin
      $fatal(1, "[Boundary Seq] Write 0x0 failed!");
    end
    tx.print();
    seqr.seq2drv_mbx.put(tx);
    seqr.tx_count++;

    tx = new();
    if (!tx.randomize() with { enable == 1'b0; rst_n == 1'b1; address == 4'h0; }) begin
      $fatal(1, "[Boundary Seq] Read 0x0 failed!");
    end
    tx.print();
    seqr.seq2drv_mbx.put(tx);
    seqr.tx_count++;

    // Upper Boundary (0xF)
    tx = new();
    if (!tx.randomize() with { enable == 1'b1; rst_n == 1'b1; address == 4'hF; }) begin
      $fatal(1, "[Boundary Seq] Write 0xF failed!");
    end
    tx.print();
    seqr.seq2drv_mbx.put(tx);
    seqr.tx_count++;

    tx = new();
    if (!tx.randomize() with { enable == 1'b0; rst_n == 1'b1; address == 4'hF; }) begin
      $fatal(1, "[Boundary Seq] Read 0xF failed!");
    end
    tx.print();
    seqr.seq2drv_mbx.put(tx);
    seqr.tx_count++;
  endtask
endclass


// 4. Read/Write Toggling Sequence
class toggle_seq extends base_sequence;

  // local golden record of every address this sequence has written so far
  bit [WADDR-1:0] written_addrs[$];

  function new(sequencer seqr);
    super.new(seqr);
  endfunction

  virtual task run();
    transaction tx_write;
    transaction tx_read;
    int idx;

    repeat (seqr.loop_count) begin
      tx_write = new();
      if (!tx_write.randomize() with { enable == 1'b1; rst_n == 1'b1; }) begin
        $fatal(1, "[Toggle Seq] Write randomization failed!");
      end
      tx_write.print();
      seqr.seq2drv_mbx.put(tx_write);
      seqr.tx_count++;

      written_addrs.push_back(tx_write.address);

      tx_read = new();
      idx = $urandom_range(written_addrs.size() - 1, 0);
      if (!tx_read.randomize() with { enable == 1'b0; rst_n == 1'b1; address == written_addrs[idx]; }) begin
        $fatal(1, "[Toggle Seq] Read randomization failed!");
      end
      tx_read.print();
      seqr.seq2drv_mbx.put(tx_read);
      seqr.tx_count++;
    end
  endtask
endclass


// 5. Full Address Sweep Sequence
class sweep_seq extends base_sequence;

  function new(sequencer seqr);
    super.new(seqr);
  endfunction

  virtual task run();
    transaction tx;

    // Sweep Write across all depths
    for (int i = 0; i < pckg::DEPTH; i++) begin
      tx = new();
      if (!tx.randomize() with { enable == 1'b1; rst_n == 1'b1; address == i[3:0]; }) begin
        $fatal(1, $sformatf("[Sweep Seq] Write failed at 0x%0h", i));
      end
      tx.print();
      seqr.seq2drv_mbx.put(tx);
      seqr.tx_count++;
    end

    // Sweep Read across all depths
    for (int i = 0; i < pckg::DEPTH; i++) begin
      tx = new();
      if (!tx.randomize() with { enable == 1'b0; rst_n == 1'b1; address == i[3:0]; }) begin
        $fatal(1, $sformatf("[Sweep Seq] Read failed at 0x%0h", i));
      end
      tx.print();
      seqr.seq2drv_mbx.put(tx);
      seqr.tx_count++;
    end
  endtask
endclass