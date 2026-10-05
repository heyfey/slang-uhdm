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
    logic [7:0] v; int k; int d[];
    k = 1; v = 8; d = new[v[k+:2]];
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
