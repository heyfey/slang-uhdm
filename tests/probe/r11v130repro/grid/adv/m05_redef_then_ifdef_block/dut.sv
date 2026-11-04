// § emptyRedefineObjLine130
`define X
`define X
`ifdef X
module top(input logic [3:0] a, output logic [3:0] o);
`else
module top(input logic [3:0] a, output logic [3:0] b);
`endif
  logic [3:0] q;
  assign q = a;
  assign o = q;
endmodule
