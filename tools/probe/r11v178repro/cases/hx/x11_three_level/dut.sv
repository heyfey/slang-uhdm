// § hierPathSelIdxAtPath178
module top;
  typedef struct { int y; } t_t;
  typedef struct { t_t x[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, j, r1, r2;
  initial begin
    r1 = m.w[k].x[j+1].y;
    r2 = m.w[k+1].x[j].y;
  end
endmodule
