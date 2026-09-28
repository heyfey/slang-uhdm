// § genScopeRangeQueryFold216 — $right of a hex-bounded parameter, macro-written assignment
`define Q(x) $right(x)
module top();
  parameter [8'h7:4'd2] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = `Q(a);
  end
endmodule
