// § ppOutputInclLine166
`define TWO(a, b) \
  assign a = 1'b0; \
  assign b = 1'b1;
module top(output o, p, q);
  `TWO(o, p)
`include "m.svh"
endmodule
