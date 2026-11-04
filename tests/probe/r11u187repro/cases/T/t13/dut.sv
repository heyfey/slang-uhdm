// § trailIdxCallArgNamesByPath187 (this and super paths)
package p;
  typedef struct { logic [3:0] q; } m_t;
  class b;
    m_t m;
  endclass
  class c extends b;
    function int f(int x); return x; endfunction
    function logic get(int k);
      logic r;
      r = this.m.q[f(k)];
      r = super.m.q[f(k)];
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
