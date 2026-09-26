// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  function automatic int f(int k);
    return m.w[k].v;
  endfunction
  int r;
  initial r = f(1);
endmodule
