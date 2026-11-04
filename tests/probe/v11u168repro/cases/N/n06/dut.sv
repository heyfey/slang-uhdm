// § ppOutputLine166
`define ML(y, x) \
  assign y = \
    x;
module top(input logic a, output logic y, output logic z);
  `ML(y, a)
`line 40 "other.sv" 0
  assign z = a;
endmodule
