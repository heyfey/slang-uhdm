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
    logic [3:0] arr[4][4]; int k; int d[];
    k = 1; d = new[arr[k][k][1:0]];
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
