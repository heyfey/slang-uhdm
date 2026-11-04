// § ppOutputLine166
`define IN(y, x) \
  assign y = \
    x;
`define OUT(y, x) `IN(y, x)
module top(input logic a, output logic y, output logic z);
  `OUT(y, a) assign z = a;
endmodule
