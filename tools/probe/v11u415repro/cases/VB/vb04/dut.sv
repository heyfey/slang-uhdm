// § badCastSizeNoExpr415
module top #(parameter W = 2) (input logic [3:0] x, output logic [1:0] z [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    always_comb z[i] = W'(x[i]);
  end
endmodule
