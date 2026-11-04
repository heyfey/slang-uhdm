// § castModTypeParamDefaultTs294
// keyword and signed defaults
module top #(parameter type T = int, parameter type U = logic signed [3:0], parameter type V = byte) (input logic [3:0] a, output int y, z, w);
  always_comb y = T'(a);
  assign z = U'(a);
  initial w = V'(a);
endmodule
