// § emptyRedefineObjLine130
`define X
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
`define X
  assign q = a;
  assign o = q;
endmodule
