// § lvIdxReadNestedKeepsLvalue181v § lvIdxReadCallNameSpan181v § lvIdxMixedPathIsRead181 (r11u190: a nested lvalue index path with a CALL two levels down)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  m_t m, n, o;
  int k;
  function automatic int f(int x); return x & 3; endfunction
  initial begin
    m.w[n.w[o.w[f(k)].v].v].v = 1;
    m.w[n.w[f(o.w[k].v)].v].v = 2;
  end
endmodule
