// § trailIdxCallArgNamesByPath187 (a package-qualified call)
package pk;
  function automatic int g(int x); return x; endfunction
endpackage
module top;
  typedef struct { logic [3:0] q; } m_t;
  m_t m;
  int k;
  logic r;
  initial r = m.q[pk::g(k)];
endmodule
