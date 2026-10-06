// § genLoopDirectBoundPaConst262 (a two-level for-generate, the module parameter a direct part-select bound)
module sub #(parameter int W = 3) (input logic [7:0] a, output logic [3:0] o [2][2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    for (genvar j = 0; j < 2; j++) begin : gg
      assign o[i][j] = a[W:0];
    end
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2][2]);
  sub u(.a(a), .o(o));
endmodule
