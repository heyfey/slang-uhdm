// § genScopeRangeQueryFold216 — $high of a module logic variable onto an implicit net in a gen-for, child instance
module sub();
  logic [11:8] v;
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = $high(v);
  end
endmodule
module top();
  sub u();
endmodule
