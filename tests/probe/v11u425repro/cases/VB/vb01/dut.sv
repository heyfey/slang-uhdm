// § oneTickUpperBNormalized425
module top(input logic a, output logic y, output logic z);
  parameter P = 1'B1;
  localparam Q = 1'B0;
  assign y = a & P;
  assign z = a | Q;
endmodule
