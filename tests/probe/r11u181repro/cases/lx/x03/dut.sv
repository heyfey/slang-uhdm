// § lvIdxMixedPathIsRead181 — control: the same nested path in an rvalue path's index (pass 178's h09 shape) and in a plain select's index on the right-hand side
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n;
  int k, y, a [8];
  initial begin
    y = m.w[n.w[k].v + 1].v;
    y = a[n.w[k].v];
  end
endmodule
