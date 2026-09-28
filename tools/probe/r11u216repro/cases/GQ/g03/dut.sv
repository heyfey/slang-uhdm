// § genScopeRangeQueryFold216 — $high of an input port onto a gen-local declared net
module top(input logic [6:3] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    wire [7:0] w;
    assign w = $high(i);
  end
  assign o = g[0].w;
endmodule
