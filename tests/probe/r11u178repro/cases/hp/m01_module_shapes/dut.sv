// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; int x[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  s_t a[4];
  int k, i, j, r1, r2, r3, r4, r5, r6;
  initial begin
    r1 = a[k].v;
    r2 = m.w[k].v;
    r3 = m.w[k].x[j];
    r4 = m.w[k+1].v;
    r5 = m.w[i].x[j];
    r6 = m.w[2].v;
  end
endmodule
