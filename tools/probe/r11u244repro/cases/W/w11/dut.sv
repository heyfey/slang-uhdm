// § cloneNewArrayCallParented244
package p;
  class hh; int q[$]; endclass
  class fac;
    int m_sz;
    int md[];
    hh h;
    extern function void emit();
    function int g(int a); return a + 1; endfunction
  endclass
  function void fac::emit();
    int n; int d[];
    n = 4; d = new[$clog2(n)];
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void f();
      fac x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  fac z;
  u w;
  initial w = new();
endmodule
