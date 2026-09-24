// § emptyRedefineObjLine130
// case r01: three consecutive empty bare redefinitions of the same macro
`define X
`define X
`define X
module top(input logic a, output logic y);
  assign y = ~a;
endmodule
