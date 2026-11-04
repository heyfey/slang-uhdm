// § genScopeRangeQueryFold216 — $low of an ascending ranged parameter in a single-level gen-for
module top();
  parameter [1:5] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = $low(a);
  end
endmodule
