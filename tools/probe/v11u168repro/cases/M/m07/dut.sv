// § ppOutputLine166
`define ML(y, x) \
  assign y = \
    x;
module top(input logic a, input logic b, output logic y, output logic z);
  wire w;
  assign z = b; `ML(y, a) assign w = a;
endmodule
