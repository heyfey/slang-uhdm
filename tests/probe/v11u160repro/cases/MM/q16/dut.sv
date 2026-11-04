// § ppMacroBodyLines160
`define ASGN(n, v) \
`ifdef NOPE \
  assign n = ~v; \
`endif \
  assign n = v;
module top (input logic a, output logic y, output logic w);
  `ASGN(y, a)
  `ASGN(w, a)
endmodule
