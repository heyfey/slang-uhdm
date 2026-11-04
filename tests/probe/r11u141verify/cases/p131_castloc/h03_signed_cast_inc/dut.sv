// § castTsPushLaidOut131
// case h03: signed cast and a width cast in an include at column 3
module top(input logic [15:0] a, output logic [5:0] o);
  `include "body.svh"
endmodule
