// § hpIdxCallNameSpan184: calls as select indices inside rvalue hier_paths (member and base selects, trailing and not, in an operation)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; logic [3:0] q; } m_t;
  m_t m;
  int k, r1, r2, r3, r4, r5, r6, r7;
  function automatic int f(int x); return x; endfunction
  function automatic int g(); return 1; endfunction
  initial begin
    r1 = m.w[f(k)].v;
    r2 = m.w[g()].v;
    r3 = m.q[f(k)];
    r4 = m.w[f(g())].v;
    r5 = m.w[f(k) + 1].v;
    r6 = m.w[k].v + f(k);
    r7 = m.w[$clog2(k)].v;
  end
endmodule
