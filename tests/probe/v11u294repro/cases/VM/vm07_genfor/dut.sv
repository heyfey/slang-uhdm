// § castModTypeParamDefaultTs294
// a cast in a for-generate process and an if-generate assign
module top #(parameter type T = logic [1:0]) (input logic [3:0] a, output logic [1:0] y [2], output logic [1:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb y[i] = T'(a[i]);
  end
  if (1) begin : h
    assign z = T'(a);
  end
endmodule
