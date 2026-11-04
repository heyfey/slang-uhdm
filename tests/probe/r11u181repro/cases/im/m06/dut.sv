// § lvSelIdxChainName181 — assignment lvalue member paths through selects in a generate scope's always_comb
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  for (genvar g = 0; g < 2; g++) begin : G
    m_t r;
    always_comb begin r.w[g].v = 3; r.w[g+1].v = 4; end
  end
endmodule
