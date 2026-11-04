// § castTsPushLaidOut131
// case h02: typedef-target cast in an include at column 3
module top(input logic [15:0] a, output logic [5:0] o);
  typedef logic [5:0] t;
  `include "body.svh"
endmodule
