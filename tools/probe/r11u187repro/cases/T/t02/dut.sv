// § trailIdxCallArgNamesByPath187
module top(input int k, output logic o, output logic p);
  typedef struct packed { logic [3:0] q; logic [3:0] w; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  assign o = m.q[f(k)];
  assign p = m.w[f(k) - 1];
endmodule
