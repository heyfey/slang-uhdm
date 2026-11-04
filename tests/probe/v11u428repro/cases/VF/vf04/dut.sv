// § ansiLogicLeaderFollowerNet428
module m(input clk, logic [3:0] a, b, c, output [3:0] o);
  assign o = b & c;
endmodule
module top(input clk, input [3:0] x, output [3:0] o1, o2);
  m u1(clk, x, x, x, o1);
  m u2(.clk(clk), .a(x), .b(x), .c(x), .o(o2));
endmodule
