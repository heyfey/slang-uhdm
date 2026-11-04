// § emptyRedefineObjLine130
`define X
`define X
`define ONE 4'd1
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
  assign q = a + `ONE;
  assign o = q;
endmodule
