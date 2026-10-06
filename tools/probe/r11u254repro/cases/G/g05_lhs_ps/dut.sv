// § genCaPsBoundOpChain254 (an operation part-select bound on the continuous assignment's target, a concatenation operand and a ternary)
module top #(parameter int W = 4) (input logic [7:0] a, input logic s, output logic [7:0] o [2], output logic [7:0] y [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k][W-1:0] = a[3:0];
    assign y[k] = {a[W-1:0], s ? a[W+3:W] : a[W-1:0]};
  end
endmodule
