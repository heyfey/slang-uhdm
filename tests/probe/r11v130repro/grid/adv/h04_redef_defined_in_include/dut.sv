// § emptyRedefineObjLine130
`include "defs.svh"
`define X
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
  assign q = a;
  assign o = q;
endmodule
