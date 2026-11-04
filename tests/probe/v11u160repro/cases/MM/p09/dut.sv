// § ppMacroBodyLines160
`define INNER(v) (v + 1)
`define OUTER(n, v) \
  assign n = `INNER(v); \
  assign w = `INNER(v) + `INNER(v);
module top (input logic [3:0] a, output logic [3:0] y);
  wire [3:0] w;
  `OUTER(y, a)
endmodule
