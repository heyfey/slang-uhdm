// § emptyRedefineObjLine130
`define X
`define X
module m1(input logic a, output logic y);
  assign y = a;
endmodule
module top(input logic a, output logic y);
  m1 u(.a(a), .y(y));
endmodule
