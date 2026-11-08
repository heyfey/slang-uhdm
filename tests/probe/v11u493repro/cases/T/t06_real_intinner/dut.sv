// § enumCastChainKeepsInnerCast493
module top(input int a, output real r);
  assign r = real'(int'(a));
endmodule
