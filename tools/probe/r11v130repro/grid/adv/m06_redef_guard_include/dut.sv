// § emptyRedefineObjLine130
`include "g.svh"
`include "g.svh"
`define G_SVH
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
  assign q = a;
  assign o = q;
endmodule
