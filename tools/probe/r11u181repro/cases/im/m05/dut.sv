// § lvSelIdxChainName181 § classMethodLvIsProcess181 — assignment lvalue member paths through selects in a class method
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  class C; m_t q; function void g(int j); q.w[j].v = 1; q.w[j+1].v = 2; endfunction endclass
  initial begin C c = new; c.g(1); end
endmodule
