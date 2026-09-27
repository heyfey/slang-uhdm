// § trailIdxCallArgNamesByPath187 (inc/dec operands, unary and call indices)
module top;
  typedef struct { int q[4]; } m_t;
  m_t m;
  int k, r;
  function automatic int f(int x); return x; endfunction
  initial begin
    m.q[f(k)]++;
    --m.q[f(k)];
    r = m.q[-f(k)];
    r = m.q[~k];
  end
endmodule
