// § enumCastChainKeepsInnerCast493
module top(input int a, output int v [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign v[i] = int'(int'(a + i));
  end
endmodule
