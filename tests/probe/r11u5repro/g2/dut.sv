package p;
  parameter int LfsrWidth = 32;
  typedef logic [LfsrWidth-1:0] lfsr_seed_t;
  typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] lfsr_perm_t;
  parameter lfsr_seed_t SeedDflt = 32'hac533bf4;
  parameter lfsr_perm_t PermDflt = {160'h1e35ecba467fd1b12e958152c04fa43878a8daed};
endpackage

module top(input logic a, output logic b);
  assign b = a;
endmodule
