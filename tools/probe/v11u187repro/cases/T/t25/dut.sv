// § trailIdxCallArgNamesByPath187 (inside a function body with a formal, package function)
package pk;
  typedef struct packed { logic [7:0] q; } m_t;
  function automatic int f(int x); return x; endfunction
  function automatic logic g(m_t m, int k); return m.q[f(k)]; endfunction
endpackage
module top(input int k, output logic o);
  import pk::*;
  m_t m;
  function automatic logic h(int j); return m.q[f(j)]; endfunction
  assign o = g(m, k) ^ h(k);
endmodule
