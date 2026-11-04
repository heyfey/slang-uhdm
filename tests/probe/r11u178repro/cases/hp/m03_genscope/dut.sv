// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int r[4];
  int k;
  for (genvar g = 0; g < 2; g++) begin : gb
    assign r[g] = m.w[k].v;
    always_comb r[g+2] = m.w[g].v;
  end
endmodule
