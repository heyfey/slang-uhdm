// § incDecMixedPathIsLvalue181 § lvSelIdxChainName181 § classMethodLvIsProcess181 — inc/dec member paths in always_comb, a function, a class method and a generate scope
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  function automatic void f(int j); m.w[j].v++; endfunction
  class C; m_t q; function void g(int j); q.w[j].v--; endfunction endclass
  for (genvar g = 0; g < 2; g++) begin : G
    m_t r;
    always_comb r.w[g].v++;
  end
  initial begin C c = new; f(k); c.g(k); end
endmodule
