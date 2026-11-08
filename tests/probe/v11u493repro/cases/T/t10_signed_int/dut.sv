// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  assign v = signed'(int'(a));
endmodule
