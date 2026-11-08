// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  typedef int t32;
  assign v = t32'(a);
endmodule
