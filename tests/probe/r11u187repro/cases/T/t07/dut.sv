// § trailIdxCallArgNamesByPath187 (a class method: the package separator)
package p;
  typedef struct { logic [3:0] q; } m_t;
  class c;
    m_t m;
    function int f(int x); return x; endfunction
    function logic get(int k);
      return m.q[f(k)];
    endfunction
  endclass
endpackage
module top; endmodule
