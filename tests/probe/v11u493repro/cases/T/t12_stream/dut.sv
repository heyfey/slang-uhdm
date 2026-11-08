// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  assign v = int'(int'({<<8{a}}));
endmodule
