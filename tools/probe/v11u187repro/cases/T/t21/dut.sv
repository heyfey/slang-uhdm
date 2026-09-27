// § trailIdxSelNamesByPath187 (a select under a call, a call under a select)
module top;
  typedef struct { logic [7:0] q; } m_t;
  m_t m;
  int k, j, r1, r2;
  int a[4];
  function automatic int f(int x); return x; endfunction
  initial begin
    r1 = m.q[f(a[1])];
    r2 = m.q[a[f(j)]];
  end
endmodule
