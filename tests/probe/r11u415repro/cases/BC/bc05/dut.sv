// § badCastSizeNoExpr415
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter W = 2) (input logic [3:0] x, output logic z);
  sub u (.a(W'(x)), .o(z));
endmodule
