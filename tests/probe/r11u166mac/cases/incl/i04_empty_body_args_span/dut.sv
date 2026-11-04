// § ppOutputInclLine166
`define NIL(a, b)
module top(output o, p, q);
  `NIL(o,
       p)
  assign o = 1'b0;
  assign p = 1'b1;
`include "m.svh"
endmodule
