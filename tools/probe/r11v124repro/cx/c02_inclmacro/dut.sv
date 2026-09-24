// § castTsFile124
`include "defs.svh"
module top(input logic [7:0] a, output logic [3:0] o);
  assign o = `TRUNC4(a);
endmodule
