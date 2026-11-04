// § lvIdxReadNestedKeepsLvalue181v § lvIdxMixedPathIsRead181 (v11u181 break, fixed: a path nested two levels in a member lvalue index and in a plain lvalue index)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n, o;
  int k;
  int arr[8];
  initial begin
    m.w[n.w[o.w[k].v].v].v = 2;
    arr[n.w[o.w[k].v].v] = 3;
  end
endmodule
