// § genScopeRangeQueryFold216 — $high / $low of typedef-typed variables (a packed logic typedef, a typedef of a typedef) in a gen-for
module dut (output logic [7:0] o1, output logic [7:0] o2);
  typedef logic [5:2] t_t;
  typedef t_t tt_t;
  t_t v;
  tt_t u;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o1 = $high(v);
    assign o2 = $low(u);
  end
endmodule
