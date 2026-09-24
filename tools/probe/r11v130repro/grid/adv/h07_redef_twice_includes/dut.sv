// § emptyRedefineObjLine130
`define X
`include "a.svh"
`define X
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
`include "a.svh"
  assign q = a;
  assign o = q;
endmodule
