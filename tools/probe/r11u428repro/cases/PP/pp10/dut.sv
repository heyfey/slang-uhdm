// § ansiLogicLeaderFollowerNet428
module m(input clk, logic [7:0] a, b, c [3:0], output logic o);
  assign o = clk & a[0];
endmodule
module top(input clk, input [7:0] x, y, output o);
  logic [7:0] z [3:0];
  m u(.clk(clk), .a(x), .b(y), .c(z), .o(o));
endmodule
