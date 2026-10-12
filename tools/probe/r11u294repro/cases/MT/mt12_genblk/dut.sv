// § castModTypeParamDefaultTs294
// a cast in a generate block (definition view keeps its own shape)
module top #(parameter type T = logic [7:0]) (input logic [3:0] a, output logic [7:0] y);
  if (1) begin : g
    always_comb y = T'(a);
  end
endmodule
