// § genLoopDirectBoundPaConst262 (top module itself, untyped parameter, a for-generate select bound in a ternary)
module top #(parameter W = 3) (input logic [7:0] a, input logic s, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = s ? a[W:0] : a[7:W+1];
  end
endmodule
