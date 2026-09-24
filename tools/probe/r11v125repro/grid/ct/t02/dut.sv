// § castTsDrainFile125
`include "pkg.svh"
module top(input logic [15:0] a, output logic [5:0] o, output logic [3:0] s);
  assign o = p::w_t'(a);
  assign s = 4'(a);
endmodule
