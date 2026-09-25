// § ppOutputFile166
`include "prim.svh"
module top(input clk_i, input rst_ni, input a, input b);
  `CHKK(ChkA, a |->
      b)
  `CHKK(ChkB, a)
endmodule
