// § ppOutputInclLine166
`define E1
`define BL(a) \
  `E1 \
  `E1
module top(output o, p, q);
  `BL(x)
  assign o = 1'b0;
  assign p = 1'b1;
`include "m.svh"
endmodule
