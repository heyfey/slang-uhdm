// § enumCastChainKeepsInnerCast493
module top(input real a, output int r);
  assign r = int'(real'(a));
endmodule
