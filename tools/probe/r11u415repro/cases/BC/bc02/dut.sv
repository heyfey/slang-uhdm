// § badCastSizeNoExpr415
module sub(input logic [3:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter W = 4) (input logic [3:0] x, output logic [1:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u (.a(W'(x[i+1])), .o(z[i]));
  end
endmodule
