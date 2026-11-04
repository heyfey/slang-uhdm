// § castModTypeParamDefaultTs294
// a type parameter defaulting to another
module top #(parameter type T = logic [3:0], parameter type U = T) (input logic a, output logic [3:0] y);
  always_comb y = U'(a);
endmodule
