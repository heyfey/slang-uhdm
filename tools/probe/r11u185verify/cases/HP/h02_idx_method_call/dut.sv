// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; logic [7:0] u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int q[$];
  int a[4];
  int r1, r2, r3;
  initial begin
    r1 = m.w[q.size()].v;
    r2 = m.w[$size(a) - 1].v;
    r3 = m.w[q.size() - 1].u[q[0]];
  end
endmodule
