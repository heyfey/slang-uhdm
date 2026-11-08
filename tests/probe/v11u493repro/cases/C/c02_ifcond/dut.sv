// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  always_comb begin
    if (int'(int'(a))) v = 1; else v = 0;
  end
endmodule
