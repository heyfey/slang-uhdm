// § ppMacroBodyLines160
`define INNER(x) assign x = 1'b0;
`define ASGN(n, v) \
`ifdef NOPE \
  `INNER(n) \
`endif \
  assign n = v;
module top (input logic a, output logic y);
  `ASGN(y, a)
endmodule
