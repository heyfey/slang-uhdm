// § hierPathSelIdxAtPath178
module top;
  typedef struct { logic [7:0] v[4]; } t_t;
  typedef struct { t_t u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int i, j, k, r1, r2;
  initial begin
    r1 = m.w[i].u[j].v[k];
    r2 = m.w[i+1].u[j*2].v[k-1];
  end
endmodule
