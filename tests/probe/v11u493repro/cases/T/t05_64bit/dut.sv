// § enumCastChainKeepsInnerCast493
module top(input longint a, output longint w);
  assign w = longint'(64'(a));
endmodule
