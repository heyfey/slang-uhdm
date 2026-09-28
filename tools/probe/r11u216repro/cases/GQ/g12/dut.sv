// § genScopeRangeQueryFold216 — $high of a descending ranged parameter in a nested generate scope
module top();
  parameter [4:1] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    if (1) begin : h
      assign ccc = $high(a);
    end
  end
endmodule
