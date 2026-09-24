// § includeNoTextSplicesNothing130
`define PRE 1
`include "defs.svh"
module top(input logic [3:0] a, output logic [3:0] o);
`include "body.svh"
  assign o = q;
endmodule
