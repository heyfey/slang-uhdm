// § enumCastChainKeepsInnerCast493
module top(input int a, input int b, input logic c, output int v);
  assign v = int'(int'(c ? a : b));
endmodule
