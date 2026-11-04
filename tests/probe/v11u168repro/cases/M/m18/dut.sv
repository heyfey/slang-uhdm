// § ppOutputLine166
`define IN(y, x) \
  assign y = \
    x;
`define OUT(y, z, x) \
  `IN(y, x) \
  `IN(z, ~x)
module top(input logic a, output logic y, output logic z);
  `OUT(y, z, a)
endmodule
