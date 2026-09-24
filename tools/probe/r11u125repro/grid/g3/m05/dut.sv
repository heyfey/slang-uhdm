// § macroTokenFileFollowsLine125
`include "defs.svh"
module top(input a, b, output o, p);
  `ASN2(o, a ^ b)
endmodule
