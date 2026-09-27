// § trailIdxCallArgNamesByPath187 (control: a non-trailing select keeps the scope name)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, r1;
  function automatic int f(int x); return x; endfunction
  initial r1 = m.w[f(k)].v;
endmodule
