// § ppOutputFile166
`include "defs.svh"
module top(output o, p, q);
  assign q = 1'b0; `TWO(o, p)
endmodule
