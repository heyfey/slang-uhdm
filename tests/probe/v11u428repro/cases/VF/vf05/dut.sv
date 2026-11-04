// § ansiLogicLeaderFollowerNet428
module m(input clk, logic [3:0] a, b, output o);
  assign o = b[0];
endmodule
module top(input clk, input [3:0] x, output [1:0] o);
  for (genvar i = 0; i < 2; i++) begin: g
    m u(.clk(clk), .a(x), .b(x), .o(o[i]));
  end
endmodule
