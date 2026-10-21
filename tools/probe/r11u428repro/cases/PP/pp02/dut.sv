// § ansiLogicLeaderFollowerNet428
module top(input clk, logic [3:0] a, b, output o);
  assign o = b[0] & clk;
endmodule
