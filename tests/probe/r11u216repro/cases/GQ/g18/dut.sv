// § genScopeRangeQueryFold216 — $high of a ranged parameter overridden per instance, in the child's gen-for
module sub #(parameter [7:0] a = 3) ();
  for (genvar i = 0; i < 1; i++) begin : g
    assign ccc = $high(a);
  end
endmodule
module top();
  sub #(.a(5)) u1();
  sub u2();
endmodule
