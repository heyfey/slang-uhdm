// § genScopeRangeQueryFold216 — $high of an input port in a nested generate scope
module top(input logic [6:3] i);
  for (genvar k = 0; k < 2; k++) begin : g
    if (1) begin : h
      assign ccc = $high(i);
    end
  end
endmodule
