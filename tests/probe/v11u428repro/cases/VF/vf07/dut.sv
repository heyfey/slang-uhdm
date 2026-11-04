// § ansiLogicLeaderFollowerNet428
module top(output o, logic [3:0] a, b);
  assign b = a;
  assign o = a[0];
endmodule
