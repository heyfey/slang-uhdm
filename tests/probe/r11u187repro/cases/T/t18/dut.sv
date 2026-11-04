// § trailIdxCallArgNamesByPath187 (a macro-born path)
`define RD(S, K) S.q[f(K)]
module top;
  typedef struct { logic [3:0] q; } m_t;
  m_t m;
  int k;
  logic r;
  function automatic int f(int x); return x; endfunction
  initial r = `RD(m, k);
endmodule
