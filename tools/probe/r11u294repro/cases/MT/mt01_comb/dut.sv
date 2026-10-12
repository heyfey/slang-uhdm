// § castModTypeParamDefaultTs294
// always_comb cast to a module type parameter defaulting to a ranged logic (the c16 shape)
module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, output logic [1:0] y);
  always_comb y = idx_t'(a);
endmodule
