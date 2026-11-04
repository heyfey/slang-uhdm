// § hierPathSelIdxCloneKeepsElem178v
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  initial begin
    m.w[k+1].v++;
    ++m.w[k+1].v;
    m.w[k+1].v += 2;
  end
endmodule
