// § trailIdxCallArgNamesByPath187 (named argument, two arguments, method call index)
class cc;
  function int get(int x); return x; endfunction
endclass
module top;
  typedef struct { logic [7:0] q; } m_t;
  m_t m;
  int k, j, r1, r2, r3;
  cc h;
  function automatic int f(int x, int y = 0); return x + y; endfunction
  initial begin
    r1 = m.q[f(.x(k))];
    r2 = m.q[f(k, j)];
    r3 = m.q[h.get(k)];
  end
endmodule
