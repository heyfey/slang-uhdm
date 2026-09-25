// § ppOutputInclLine166
`define TWO(a, b) \
`ifdef NOPE \
  assign a = 1'b1; \
`else \
  assign a = 1'b0; \
`endif \
  assign b = 1'b1;
module top(output o, p, q);
  `TWO(o, p)
`include "m.svh"
endmodule
