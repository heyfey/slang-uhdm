// § refFullNameThroughNamedExpr175
module top;
  typedef struct { int x[4]; } s_t;
  if (1) begin : G
    s_t m;
    function automatic int f(int k, int a = k); return m.x[k] + a; endfunction
  end
  int r; initial r = G.f(1);
endmodule
