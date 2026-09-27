// § splitPortIntRedeclLogicTs180 (verifier: an instantiated child with the split integer port, parent reads it)
module child (a, b);
  input  [3:0] a;
  output b;
  integer b;
  always @(*) b = a - 1;
endmodule
module top(input logic [3:0] a, output logic [31:0] y);
  child c(.a(a), .b(y));
endmodule
