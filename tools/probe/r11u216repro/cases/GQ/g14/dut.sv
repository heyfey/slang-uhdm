// § genScopeRangeQueryFold216 — $high of a logic-typed ranged parameter and of an int parameter (no written range)
module top();
  parameter logic [7:3] a = 3;
  parameter int b = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign c1 = $high(a);
    assign c2 = $high(b);
  end
endmodule
