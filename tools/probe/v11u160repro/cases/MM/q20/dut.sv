// § ppMacroBodyLines160
`define ASGN(n, v) \
  assign n = v; \
  assign n``_q = v;
module top (input logic a, output logic y, output logic y_q, output logic w, output logic w_q);
  `ASGN(y, a) `ASGN(w, a)
endmodule
