// § genScopeRangeQueryFold216 — the queried range written by a macro (the bound inside the expansion)
`define RNG [4:1]
module top();
  parameter `RNG a = 3;
  logic `RNG v;
  for (genvar i = 0; i < 2; i++) begin : g
    assign c1 = $high(a);
    assign c2 = $low(v);
  end
endmodule
