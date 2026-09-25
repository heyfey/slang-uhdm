// § ppMacroBodyLines160
`define INNER(a, b) a + b
`define OUTER(n, x) \
  assign n = `INNER(x, 1'b1) + `INNER(1'b0, x); \
  assign w = x;
module top (input logic x, output logic [1:0] y, output logic w);
  `OUTER(y, x)
endmodule
