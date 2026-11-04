// § castTsDrainFile125
`include "defs.svh"
module top(input logic [15:0] a, output logic [7:0] o);
  typedef logic [7:0] byte_t;
  assign o = `TOB(a);
endmodule
