package pckg;
  parameter WIDTH = 16;
  parameter WADDR = 4;
  localparam DEPTH = 1 << WADDR;

  `include "TransactionClass.svh"
  `include "SequencerClass.svh"
  `include "seq_children.svh"
  `include "DriverClass.svh"
  `include "MonitorClass.svh"
  `include "ScoreboardClass.svh"
  `include "SubscriberClass.svh"
  `include "EnvClass.svh"

endpackage
