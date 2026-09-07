// v196 arm X8 — the file-scope import comes out of a MACRO expansion.
`define V196IMP import quarryPkg::*;
`V196IMP
module xMac(input int a, output int b);
  assign b = a + quarryTake(6);
endmodule
