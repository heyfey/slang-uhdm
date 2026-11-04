// § ppReincludeSplice166
`include "g.svh"
module top(output o);
  assign o = 1'b0;
`include "g.svh"
`include "m.svh"
endmodule
