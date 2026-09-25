// § ppOutputCol166
`define C(y,a) assign y = a; // trailing
module top(input logic a, output logic y, output logic z);
  `C(y, a) assign z = a;
endmodule
