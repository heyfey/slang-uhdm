// § ppMacroBodyLines160
`define ASGN(n, v) \
  assign n = v; \
\
  assign w = v;
module top (input logic a, output logic y, output logic w);
  `ASGN(y, a)
endmodule
