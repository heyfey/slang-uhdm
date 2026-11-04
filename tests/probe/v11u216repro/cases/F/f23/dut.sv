// § rqParamOpBoundAtCall216v (with § genScopeRangeQueryFold216) — a module parameter with bound W-1 ($high, INT) and a localparam with bound W+1 read in a gen-if
module top #(parameter int W = 4, parameter logic [W-1:0] P = 2) (output logic [7:0] c, output logic [7:0] d);
  localparam logic [W+1:0] L = 3;
  if (1) begin : g
    assign c = $high(P);
    assign d = $high(L);
  end
endmodule
