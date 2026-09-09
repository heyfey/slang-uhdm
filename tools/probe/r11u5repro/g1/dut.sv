package p;
  parameter int LfsrWidth = 32;
  parameter int unsigned PMP_ADDR_MSB = 33;
  typedef logic [LfsrWidth-1:0] lfsr_seed_t;
  typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] lfsr_perm_t;
  parameter lfsr_seed_t SeedDflt = 32'hac533bf4;
  parameter lfsr_perm_t PermDflt = {160'h1e35ecba467fd1b12e958152c04fa43878a8daed};
  parameter logic [PMP_ADDR_MSB:0] AddrRst = 34'h0;
endpackage

module top;
  import p::*;
  logic [LfsrWidth-1:0] x;
  assign x = SeedDflt;
endmodule
