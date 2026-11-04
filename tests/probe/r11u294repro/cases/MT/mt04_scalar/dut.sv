// § castModTypeParamDefaultTs294
// the default is a scalar logic
module top #(parameter type T = logic) (input logic [3:0] a, output logic y);
  always_comb y = T'(a);
endmodule
