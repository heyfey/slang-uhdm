// § castModTypeParamDefaultTs294
// the default is logic [7:0]
module top #(parameter type T = logic [7:0]) (input logic [3:0] a, output logic [7:0] y);
  always_comb y = T'(a);
endmodule
