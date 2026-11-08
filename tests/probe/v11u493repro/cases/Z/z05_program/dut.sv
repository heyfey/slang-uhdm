// § enumCastChainKeepsInnerCast493
program prg(input int a);
  int b;
  initial b = int'(int'(a));
endprogram
module top(input int a);
  prg pp(a);
endmodule
