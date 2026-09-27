// § trailIdxCallArgNamesByPath187 (inc/dec and nested paths in the index)
module top;
  typedef struct { int q[4]; int w[4]; } m_t;
  m_t m, n;
  int k;
  function automatic int f(int x); return x; endfunction
  initial begin
    m.q[f(k)]++;
    m.q[f(n.w[k])] = 1;
    k = m.q[f(n.w[f(k)])];
  end
endmodule
