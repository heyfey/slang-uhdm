// § ppOutputCol166
`define D(a, b=1) \
  assign a = \
    b;
module top(output logic y, output logic z);
  `D(y)
  `D(z, 0)
endmodule
