// § oneTickUpperBNormalized425
`define ONE 1'B1
`define ZERO 1'B0
module top(input logic a, output logic y, output logic z);
  assign y = a & `ONE;
  assign z = a | `ZERO;
endmodule
