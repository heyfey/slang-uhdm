// § genScopeRangeQueryFold216 — $low, $left and $right of a ranged parameter onto implicit nets in a gen-for
module top();
  parameter [4:1] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign c1 = $low(a);
    assign c2 = $left(a);
    assign c3 = $right(a);
  end
endmodule
