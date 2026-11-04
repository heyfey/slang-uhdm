// § genScopeRangeQueryFold216 — $high of a parameter-sized port (bound W-1) in a gen-for
module top #(parameter int W = 6) (input logic [W-1:0] i);
  for (genvar k = 0; k < 2; k++) begin : g
    assign ccc = $high(i);
  end
endmodule
