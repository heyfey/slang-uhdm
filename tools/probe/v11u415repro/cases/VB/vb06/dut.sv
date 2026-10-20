// § badCastSizeNoExpr415
module sub #(parameter W = 2) (input logic [W-1:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter W = 3) (input logic [3:0] x, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    sub #(.W(W)) u (.a(W'(x)), .o(z[i]));
  end
endmodule
