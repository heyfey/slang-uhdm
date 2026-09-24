// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input [7:0] b, output [7:0] o);
  assign o = `A + b;
endmodule
