// § ppOutputCol166
`define INV ~
module top(input logic a, output logic y, output logic z);
  assign y = `INV (a);
  assign z = `INV(a) & a;
endmodule
