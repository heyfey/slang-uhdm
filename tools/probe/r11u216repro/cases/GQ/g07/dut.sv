// § genScopeRangeQueryFold216 — $size of a ranged parameter in a gen-for (control: not a bound query)
module top();
  parameter [4:1] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = $size(a);
  end
endmodule
