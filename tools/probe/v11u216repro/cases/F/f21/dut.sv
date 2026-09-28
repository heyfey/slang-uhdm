// § rqParamOpBoundAtCall216v (with § genScopeRangeQueryFold216) — a ranged parameter overridden per instance (bound W+2) read in a child's gen-for
module sub #(parameter int W = 2, parameter logic [W+2:0] P = 1) (output logic [7:0] c);
  for (genvar k = 0; k < 1; k++) begin : g
    assign c = $high(P);
  end
endmodule
module top (output logic [7:0] c1, c2);
  sub #(.W(3)) a (.c(c1));
  sub #(.W(5)) b (.c(c2));
endmodule
