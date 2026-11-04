// § lvIdxReadNestedKeepsLvalue181v § lvIdxMixedPathIsRead181 (v11u181 break, fixed: a path nested two levels in lvalue indices: nonblocking, compound, part-select lvalue, a member lvalue)
module top(input logic clk);
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m, n, o;
  int k;
  logic [15:0] vec;
  always_ff @(posedge clk) m.w[n.w[k].v + o.w[k].v].v <= 1;
  initial begin
    m.w[n.w[o.w[k].v].v].v += 2;
    vec[n.w[k].v +: 4] = 4'h3;
    m.w[n.w[k].v].v = n.w[k+1].v;
  end
endmodule
