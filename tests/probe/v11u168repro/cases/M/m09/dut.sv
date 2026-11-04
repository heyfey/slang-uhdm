// § ppOutputLine166
`define ML(y, x) \
  assign y = \
    x;
module top(input logic a, input logic b, output logic y, output logic z);
  `ML(y, a) `ML(z, b)
endmodule
