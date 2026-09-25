// § ppOutputLine166
`define ML(y, x) \
  /* comment */ \
  assign y = /* c2 */ \
    x;
module top(input logic a, output logic y);
  `ML(y, a)
endmodule
