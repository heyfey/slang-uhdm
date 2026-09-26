// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w2[4][4]; } m_t;
  m_t m;
  s_t a2[4][4];
  int k, j, r1, r2, r3;
  initial begin
    r1 = m.w2[k][j+1].v;
    r2 = m.w2[k+1][j].v;
    r3 = a2[k+1][j].v;
  end
endmodule
