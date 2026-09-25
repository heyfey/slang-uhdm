// § ppOutputInclLine166
`define ONE(a, b) assign a = b;
module top(output o, p, q);
  `ONE(o,
       1'b0)
  assign p = 1'b1;
`include "m.svh"
endmodule
