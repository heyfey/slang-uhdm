// § castModTypeParamDefaultTs294
// an initial block
module top #(parameter type T = logic [7:0]) (input logic [3:0] a, output logic [7:0] y);
  initial y = T'(a);
endmodule
