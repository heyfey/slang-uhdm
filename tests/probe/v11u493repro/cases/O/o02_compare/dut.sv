// § enumCastChainKeepsInnerCast493
module top(input int a, output logic b);
  assign b = (int'(int'(a)) == 3);
endmodule
