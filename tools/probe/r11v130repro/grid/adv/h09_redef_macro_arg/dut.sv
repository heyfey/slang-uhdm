// § emptyRedefineObjLine130
`define X
`define ID(x) x
`define X
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
  assign q = `ID(a);
  assign o = `ID(
     q);
endmodule
