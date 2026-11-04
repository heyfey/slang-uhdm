// § ppOutputLine166
`define ML(y, x) \
  assign y = \
    x; \
  `define INNER 1
module top(input logic a, output logic y, output logic z);
  `ML(y, a)
  assign z = `INNER;
endmodule
