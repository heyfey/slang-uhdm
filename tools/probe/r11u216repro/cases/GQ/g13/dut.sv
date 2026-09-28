// § genScopeRangeQueryFold216 — $high of a port whose bound is a bare parameter name [W:0]
module top #(parameter int W = 6) (input logic [W:0] i);
  for (genvar k = 0; k < 2; k++) begin : g
    assign ccc = $high(i);
  end
endmodule
