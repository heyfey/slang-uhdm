// § castModTypeParamDefaultTs294
// two type parameters, casts nested and in a port default and a ternary
module top #(parameter type T = logic [3:0], parameter type U = logic [1:0]) (input logic [3:0] a, input logic c, output logic [3:0] y, output logic [1:0] z);
  assign y = c ? T'(U'(a)) : T'(a + 1);
  always_comb z = U'(T'(a) >> 1);
endmodule
