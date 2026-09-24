// § emptyRedefineObjLine130
// case r02: a macro first defined with arguments, then redefined empty and bare
`define F(a) a
`define F
module top(input logic a, output logic y);
  logic t;
  assign t = a;
  assign y = t;
endmodule
