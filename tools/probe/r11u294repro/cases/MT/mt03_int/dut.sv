// § castModTypeParamDefaultTs294
// the default is the int keyword
module top #(parameter type T = int) (input logic [3:0] a, output int y);
  always_comb y = T'(a);
endmodule
