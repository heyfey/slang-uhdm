// § badCastSizeNoExpr415
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top (input logic [3:0] x, output logic [3:0] z);
  localparam int W = 2;
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a(W'(x)), .o(z[i]));
  end
endmodule
