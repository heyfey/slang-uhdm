// § castModTypeParamDefaultTs294
// the default is a module typedef
module top #(parameter type T = logic [5:0]) (input logic [3:0] a, output logic [5:0] y);
  typedef logic [5:0] w_t;
  always_comb y = T'(a) ^ w_t'(a);
endmodule
