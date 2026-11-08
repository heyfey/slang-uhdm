// § enumCastChainKeepsInnerCast493
module top(input int a, output logic [63:0] w);
  assign w = {int'(int'(a)), 32'h0};
endmodule
