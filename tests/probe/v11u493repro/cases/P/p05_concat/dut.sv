// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  assign v = int'(int'({a[15:0], a[31:16]}));
endmodule
