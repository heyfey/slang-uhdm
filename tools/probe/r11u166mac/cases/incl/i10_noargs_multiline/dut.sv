// § ppOutputInclLine166
`define TWO \
  assign o = 1'b0; \
  assign p = 1'b1;
module top(output o, p, q);
  `TWO
`include "m.svh"
endmodule
