// § lvIdxReadNestedKeepsLvalue181v (v11u181 control: the rvalue twin of the doubly nested path, untouched by every law)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n, o;
  int k, y;
  initial begin
    y = n.w[o.w[k].v].v;
  end
endmodule
