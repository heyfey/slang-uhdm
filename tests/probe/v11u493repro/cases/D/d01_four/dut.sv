// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  assign v = int'(int'(int'(int'(a))));
endmodule
