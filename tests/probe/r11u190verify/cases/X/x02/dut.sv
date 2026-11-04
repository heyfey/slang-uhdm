// § modAggTfArgCloneFollows180 § lvIdxReadNestedKeepsLvalue181v (r11u190 cross: an aggregate formal typedef read in lvalue indices nested two levels)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  typedef struct packed { logic [1:0] k; logic [1:0] j; } ix_t;
  m_t m, n, o;
  function automatic int f(input ix_t x); return x.k; endfunction
  localparam ix_t IX = '{k:2'd1, j:2'd2};
  initial begin
    m.w[n.w[o.w[IX.k].v].v].v = 2;
    m.w[f(IX)].v = 1;
  end
endmodule
