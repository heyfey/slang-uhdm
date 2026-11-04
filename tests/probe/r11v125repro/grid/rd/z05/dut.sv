// § includeInfoEmptyRedefineLine125
`define X
`ifdef X
`define X
`endif
module top(input logic [3:0] a, output logic [3:0] o);
`include "body.svh"
  assign o = q;
endmodule
