package p;
  parameter int LfsrWidth = 32;
  typedef logic [LfsrWidth-1:0] lfsr_seed_t;
  parameter lfsr_seed_t SeedDflt = 32'hac533bf4;
endpackage

module top;
  import p::*;
  logic [LfsrWidth-1:0] x;
  assign x = SeedDflt;
endmodule
