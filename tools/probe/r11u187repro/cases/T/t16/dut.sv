// § trailIdxCallArgNamesByPath187 (paths nested in rvalue and lvalue indices)
module top;
  typedef struct { int q[4]; int w[4]; } m_t;
  m_t m, n;
  int k, r;
  function automatic int f(int x); return x; endfunction
  initial begin
    r = n.w[m.q[f(k)]];
    n.w[m.q[f(k)]] = 1;
    r = n.w[f(m.q[k])];
  end
endmodule
