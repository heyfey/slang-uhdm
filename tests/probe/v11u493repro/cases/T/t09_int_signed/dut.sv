// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  assign v = int'(signed'(a));
endmodule
