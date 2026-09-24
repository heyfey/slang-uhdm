// § includeInfoEmptyRedefineLine125
`define X 1
`define X
module top(input logic [3:0] a, output logic [3:0] o);
`include "body.svh"
  assign o = q;
endmodule
