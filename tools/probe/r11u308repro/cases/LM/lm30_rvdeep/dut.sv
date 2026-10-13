// § lvMemberSelIdxKeepsRead308
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  typedef struct packed { logic [1:0] k; logic [1:0] j; } ix_t;
  m_t m, n, o;
  ix_t t;
  initial begin
    n.w[0].v = m.w[n.w[t.k].v].v;
  end
endmodule
