// § ansiLogicLeaderFollowerNet428
module m #(parameter W = 2) (input clk, logic [W-1:0] a, b, output o);
  assign o = b[0];
endmodule
module top(input clk, input [3:0] x, output o1, o2);
  m #(4) u1(.clk(clk), .a(x), .b(x), .o(o1));
  m #(2) u2(.clk(clk), .a(x[1:0]), .b(x[1:0]), .o(o2));
endmodule
