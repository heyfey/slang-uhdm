// § oneTickUpperBNormalized425
module top(input logic a, output logic y);
  wire w = 1'B1;
  wire v = 1'B0;
  assign y = a & w & v;
endmodule
