// § ansiLogicLeaderFollowerNet428
module top(input clk, logic [3:0] a, b, wire c, output o);
  assign o = b[0] & c;
endmodule
