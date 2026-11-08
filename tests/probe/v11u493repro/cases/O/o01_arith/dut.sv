// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  always_comb v = int'(int'(a)) + 1;
endmodule
