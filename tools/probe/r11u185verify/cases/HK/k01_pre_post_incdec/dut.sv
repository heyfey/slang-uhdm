// § hierPathSelIdxCloneKeepsElem178v
module top;
  typedef struct { int v; logic [7:0] u[4]; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k, x, y;
  initial begin
    ++m.w[k+1].v;
    m.w[k*2].v--;
    x = --m.w[k].v;
    y = m.w[k+2].v++;
  end
endmodule
