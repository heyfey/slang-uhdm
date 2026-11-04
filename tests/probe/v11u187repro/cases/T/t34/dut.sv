// § trailIdxCallArgNamesByPath187 (paths nested under an operation, a call, two levels)
module top;
  typedef struct { int q[4]; int w[4]; int r[4]; } m_t;
  m_t m, n, p;
  int k, r1, r2, r3;
  function automatic int f(int x); return x; endfunction
  function automatic int g(int x); return x; endfunction
  initial begin
    r1 = n.w[m.q[f(k)] + 1];
    r2 = n.w[g(m.q[f(k)])];
    r3 = n.w[p.r[m.q[f(k)]]];
  end
endmodule
