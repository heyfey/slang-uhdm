// § lvIdxMixedPathIsRead181 § classMethodLvIsProcess181 — a member path through selects nested in a class method's lvalue index and a plain array lvalue's index
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  class C; m_t q; int a [8]; function void g(int j); q.w[q.w[j].v].v = 1; a[q.w[j].v] = 2; endfunction endclass
  initial begin C c = new; c.g(1); end
endmodule
