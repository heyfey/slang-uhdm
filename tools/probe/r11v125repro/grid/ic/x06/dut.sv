// § includeFirstLineColShift125
module top(input logic [3:0] a, output logic [3:0] o);
  `include "p.svh"
  `include "p2.svh"
  assign o = a + P + P2;
endmodule
