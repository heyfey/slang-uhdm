// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; int x[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  s_t a[4];
  int k, j;
  initial begin
    a[k].v = 1;
    m.w[k].v = 2;
    m.w[k].x[j] = 3;
    m.w[k+1].v = 4;
  end
endmodule
