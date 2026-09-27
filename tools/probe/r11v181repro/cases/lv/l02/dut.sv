// § incDecMixedPathIsLvalue181 § lvSelIdxChainName181 (v11u181 break: inc/dec member paths with a call index, a nested path index, two selects, in a module task)
module top;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; s_t x[4]; } m_t;
  m_t m, n;
  int k;
  function automatic int f(int a); return a + 1; endfunction
  task automatic t();
    m.w[k].v++;
    m.w[f(k)].v--;
    m.w[n.x[k].v].v++;
    ++m.w[k+1].v;
    m.x[k-1].v -= 1;
  endtask
  initial t();
endmodule
