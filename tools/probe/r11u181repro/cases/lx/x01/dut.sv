// § lvIdxMixedPathIsRead181 — a member path through selects nested in a procedural lvalue's select index (module initial, operation and direct index)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n;
  int k;
  initial begin
    m.w[n.w[k].v + 1].v = 2;
    m.w[n.w[k].v].v = 3;
    m.w[n.w[k+1].v].v += 1;
  end
endmodule
