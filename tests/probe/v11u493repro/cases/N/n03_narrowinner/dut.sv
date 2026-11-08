// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  assign v = int'(16'(a));
endmodule
