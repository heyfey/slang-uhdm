// § ansiLogicLeaderFollowerNet428
module m(input clk, logic [3:0] a, b, output o);
  assign o = clk;
endmodule
module top(input clk, input [3:0] x, output o, output [3:0] t);
  m u(.clk(clk), .a(x), .b(x), .o(o));
  assign t = u.b;
endmodule
