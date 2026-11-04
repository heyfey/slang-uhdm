// § ansiLogicLeaderFollowerNet428
module top(input clk, logic [3:0] a, b [1:0], output [3:0] o);
  assign o = b[1] | b[0];
endmodule
