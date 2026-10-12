// § castModTypeParamDefaultTs294
// two casts to the same type parameter
module top #(parameter int W = 4, parameter type T = logic [W-1:0]) (input logic [3:0] a, b, output logic [3:0] y);
  always_comb y = T'(a) ^ T'(b);
endmodule
