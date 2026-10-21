// § ansiLogicLeaderFollowerNet428
module top(input clk, logic [3:0] a, b, output [3:0] o);
  assign o = b ^ a;
endmodule
