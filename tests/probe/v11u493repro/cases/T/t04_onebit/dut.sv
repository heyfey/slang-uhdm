// § enumCastChainKeepsInnerCast493
module top(input logic a, output logic w);
  assign w = 1'(1'(a));
endmodule
