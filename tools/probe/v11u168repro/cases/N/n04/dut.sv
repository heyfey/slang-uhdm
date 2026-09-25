// § ppOutputLine166
`define ML(y, x) \
  assign y = \
    x;
module top(input logic a, input logic b, output logic y, output logic z);
`ifdef NOPE
  `ML(y, b)
  `ML(z, a)
`else
  `ML(y, a)
`endif
  assign z = b;
endmodule
