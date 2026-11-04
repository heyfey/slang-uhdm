// § incDecMixedPathIsLvalue181 § lvSelIdxChainName181 — inc/dec operands that are member paths through element selects (v11u178 hk/k01's shape) beside the assignment lvalue
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  initial begin
    m.w[k+1].v++;
    ++m.w[k+1].v;
    m.w[k+1].v = 3;
    m.w[k].v--;
    --m.w[2].v;
  end
endmodule
