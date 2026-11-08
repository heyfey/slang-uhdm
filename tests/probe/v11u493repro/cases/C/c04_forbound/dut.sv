// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  always_comb begin
    v = 0;
    for (int i = 0; i < int'(int'(a)); i++) v = v + 1;
  end
endmodule
