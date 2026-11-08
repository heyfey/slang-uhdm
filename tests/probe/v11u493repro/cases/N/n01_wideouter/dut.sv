// § enumCastChainKeepsInnerCast493
module top(input byte a, output int v);
  assign v = int'(byte'(a));
endmodule
