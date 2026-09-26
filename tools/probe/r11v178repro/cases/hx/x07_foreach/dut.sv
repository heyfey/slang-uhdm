// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; int x[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int r;
  initial begin
    foreach (m.w[i]) r += m.w[i].v;
    for (int i = 0; i < 3; i++) r += m.w[i].x[i+1] + m.w[i+1].x[i];
  end
endmodule
