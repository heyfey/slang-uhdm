// § trailIdxCallArgNamesByPath187
module top;
  typedef struct { logic [3:0] q; int w; } m_t;
  m_t m;
  int k, j, r1, r2, r3, r4;
  function automatic int f(int x); return x; endfunction
  function automatic int g(); return 1; endfunction
  initial begin
    r1 = m.q[f(k)];
    r2 = m.q[f(k) + j];
    r3 = m.q[f(g())];
    r4 = m.q[$clog2(k)];
  end
endmodule
