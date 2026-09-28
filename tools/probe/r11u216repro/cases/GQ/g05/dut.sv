// § genScopeRangeQueryFold216 — $low of an ascending ranged parameter in a nested generate scope
module top();
  parameter [1:5] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    if (1) begin : h
      assign ccc = $low(a);
    end
  end
endmodule
