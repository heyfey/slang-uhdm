// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  typedef struct { int k; } k_t;
  m_t m;
  k_t s;
  int k, r1, r2, r3, r4, r5;
  function automatic int f(int x); return x; endfunction
  initial begin
    r1 = m.w[f(k)].v;
    r2 = m.w[s.k].v;
    r3 = m.w[$clog2(k)].v;
    r4 = m.w[k[1:0]].v;
    r5 = m.w[-k].v;
  end
endmodule
