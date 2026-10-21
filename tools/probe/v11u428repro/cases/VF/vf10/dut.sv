// § ansiLogicLeaderFollowerNet428
module top(input clk, logic [3:0] a, [3:0] b, output o);
  assign o = b[0] & a[0];
endmodule
