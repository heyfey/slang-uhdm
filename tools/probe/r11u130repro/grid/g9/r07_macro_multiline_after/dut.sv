// § emptyRedefineObjLine130
`define X
`define X
`define ADD(a, b) \
  (a + b)
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] q;
  assign q = `ADD(a, 4'd1);
  assign o = q;
endmodule
