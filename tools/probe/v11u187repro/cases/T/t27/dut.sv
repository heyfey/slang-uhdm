// § trailIdxCallArgNamesByPath187 (two-dimensional: a call in the non-trailing index)
module top;
  typedef struct { logic [3:0][1:0] q; } m_t;
  m_t m;
  int k, j;
  logic r1, r2;
  function automatic int f(int x); return x; endfunction
  initial begin
    r1 = m.q[f(k)][j];
    r2 = m.q[j][f(k)];
  end
endmodule
