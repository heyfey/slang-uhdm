// § procLvIdxCallWholeSpan181 § lvSelIdxChainName181 — assignment lvalue member paths through selects in a module initial: operation, call, reference indices, a compound assignment
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  int k;
  function automatic int f1(int a); return a; endfunction
  initial begin
    m.w[k+1].v = 3;
    m.w[f1(k)].v = 4;
    m.w[k].v = 5;
    m.w[k*2].v += 1;
  end
endmodule
