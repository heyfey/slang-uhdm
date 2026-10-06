// § genCaPsBoundOpChain254 (indexed part-selects over a var_select with an operation base and width, in a two-level for generate)
module top #(parameter int W = 4) (input logic [1:0][15:0] a, output logic [3:0] o [2][2], output logic [3:0] p [2]);
  for (genvar k = 0; k < 2; k++) begin : g1
    for (genvar j = 0; j < 2; j++) begin : g2
      assign o[k][j] = a[k][W*j +: W];
    end
    assign p[k] = a[k][W*2-1 -: W];
  end
endmodule
