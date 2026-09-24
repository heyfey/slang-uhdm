// § macroTokenFileFollowsLine125
`include "inc1.svh"
module top(input [`W-1:0] a, output [`W-1:0] o);
  assign o = a + `ONE;
endmodule
