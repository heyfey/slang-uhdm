// § incDecMixedPathIsLvalue181 — a base-select member path and a two-level member path as inc/dec operands
module top;
  typedef struct { int v; int u; } s_t;
  typedef struct { s_t w[4]; } m_t;
  s_t a[4];
  m_t m;
  int k, x;
  initial begin
    a[k+1].v++;
    a[k].v--;
    x = a[k].u++;
    m.w[k].u++;
  end
endmodule
