// § castModTypeParamDefaultTs294
// a type parameter declared in the module body
module top (input logic [3:0] a, output logic [7:0] y);
  parameter type T = logic [7:0];
  always_comb y = T'(a);
endmodule
