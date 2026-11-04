// § defNetEndOnlyLoc130
// case a02: the anonymous enum type comes from a macro
`define ETYPE enum logic [1:0] {RED, GREEN, BLUE}
module top(output logic [1:0] o);
  `ETYPE color;
  assign o = color;
endmodule
