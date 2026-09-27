// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; logic [7:0] u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  typedef struct { logic [1:0] idx[4]; int j; } x_t;
  x_t s;
  int j, r1, r2;
  initial begin
    r1 = m.w[s.idx[j]].v;
    r2 = m.w[s.idx[s.j]].u[j];
  end
endmodule
