// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, r;
  initial r = m.w[k].v;
endmodule
