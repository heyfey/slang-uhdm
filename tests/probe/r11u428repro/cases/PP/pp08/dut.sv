// § ansiLogicLeaderFollowerNet428
module top(input clk, logic a, b, c);
  logic q;
  always @(posedge clk) q <= a ^ b ^ c;
endmodule
