// § lvSelIdxChainName181 — assignment lvalue member paths through selects in a module task and a package function
package p;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  function automatic m_t pf(int j); m_t q; q.w[j+1].v = 5; q.w[j].v = 6; return q; endfunction
endpackage
module top;
  import p::*;
  m_t m, n;
  int k;
  task automatic t(int j); m.w[j+1].v = 7; m.w[j].v = 8; endtask
  initial begin t(k); n = pf(k); end
endmodule
