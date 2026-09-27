// § trailIdxCallArgNamesByPath187 (nested paths in continuous assignments and lvalues)
module top(input int k, output int o1, output int o2);
  typedef struct packed { logic [3:0][7:0] q; logic [3:0][7:0] w; } m_t;
  m_t m, n;
  function automatic int f(int x); return x; endfunction
  assign o1 = n.w[m.q[f(k)][1:0] + 1];
  assign o2 = n.w[f(m.q[f(k)])];
  always_comb n.w[m.q[f(k)][1:0]] = 8'h1;
endmodule
