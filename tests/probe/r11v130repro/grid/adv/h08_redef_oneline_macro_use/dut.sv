// § emptyRedefineObjLine130
`define X
`define W 4
`define X
module top(input logic [`W-1:0] a, output logic [`W-1:0] o);
  logic [`W-1:0] q;
  assign q = a;
  assign o = q;
endmodule
