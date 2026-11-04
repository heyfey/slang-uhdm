// § castTsPushLaidOut131
// case h01: cast inside a nested include at column 5
module top(input logic [15:0] a, output logic [5:0] o);
  `include "outer.svh"
endmodule
