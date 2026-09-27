// § procLvIdxCallWholeSpan181 § lvSelIdxChainName181 — a call as a procedural lvalue member-path select index
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  function automatic int f(int a); return a; endfunction
  initial begin
    m.w[f(k)].v = 4;
    m.w[f(1)].v = 5;
  end
endmodule
