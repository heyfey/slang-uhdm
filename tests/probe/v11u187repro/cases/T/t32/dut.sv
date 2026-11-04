// § trailIdxCallArgNamesByPath187 (a class property path in a method)
class c;
  typedef struct { logic [7:0] q; } m_t;
  m_t m;
  int k;
  function int f(int x); return x; endfunction
  function logic g(); return m.q[f(k)]; endfunction
endclass
module top; endmodule
