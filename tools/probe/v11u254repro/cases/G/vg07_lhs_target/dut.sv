// § genCaPsBoundOpChain254 (a part-select target with operation bounds in a for generate, one and two levels down)
module top #(parameter int W = 4) (input logic [3:0] a, output logic [7:0] o [2], output logic [7:0] p [2][2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k][W*2-1:W] = a;
    assign o[k][W-1:0] = a;
    for (genvar j = 0; j < 2; j++) begin : h
      assign p[k][j][W+3:W] = a;
      assign p[k][j][W-1:0] = a;
    end
  end
endmodule
