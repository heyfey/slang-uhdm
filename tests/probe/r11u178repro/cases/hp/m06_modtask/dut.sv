// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int r;
  task automatic t(int k);
    r = m.w[k].v;
    m.w[k].v = r;
  endtask
  initial t(1);
endmodule
