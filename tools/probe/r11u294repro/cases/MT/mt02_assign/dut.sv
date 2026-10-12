// § castModTypeParamDefaultTs294
// a continuous assignment
module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, output logic [1:0] y);
  assign y = idx_t'(a);
endmodule
