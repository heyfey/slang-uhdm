// § hierPathSelIdxAtPath178 § hierPathSelIdxCloneKeepsElem178v
module top;
  typedef struct { int v; logic [7:0] u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, j;
  initial begin
    m.w[k+1].v += 2;
    m.w[k].u[j] <<= 1;
    m.w[k-1].u[j+1] |= m.w[k].v;
  end
endmodule
