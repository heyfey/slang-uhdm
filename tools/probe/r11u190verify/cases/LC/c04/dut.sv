// § lvIdxReadNestedKeepsLvalue181v § lvIdxMixedPathIsRead181 § lvIdxReadCallNameSpan181v (r11u190: paths in CALL ARGUMENTS inside a read path nested in an lvalue index; an operation control; a path nested in a call argument's own index)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  m_t m, n, o, p;
  int k;
  function automatic int f(int x); return x & 3; endfunction
  initial begin
    m.w[n.w[f(o.w[k].v) + 1].v].v = 1;
    m.w[n.w[$clog2(o.w[k].v)].v].v = 2;
    m.w[n.w[o.w[k].v + 1].v].v = 3;
    m.w[n.w[f(o.w[p.w[k].v].v)].v].v = 4;
  end
endmodule
