// § ppMacroBodyLines160
`define ONE(x) (x)
`define TWO(n, x) \
  assign n = `ONE(x) & `ONE(x); \
  assign w = `ONE(x);
module top (input logic xxxxxxxx, output logic y, output logic w);
  `TWO(y, xxxxxxxx)
endmodule
