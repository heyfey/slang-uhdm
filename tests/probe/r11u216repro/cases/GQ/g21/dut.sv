// § genScopeRangeQueryFold216 — the queried variable declared in an included header
module top();
`include "decl.svh"
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = $high(v);
  end
endmodule
