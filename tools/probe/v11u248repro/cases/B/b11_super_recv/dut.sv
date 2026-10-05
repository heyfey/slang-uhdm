// § cloneWithOperandChainName248
package p;
  class b;
    int m_v[$];
    int m_k;
  endclass
  class c extends b;
    extern function void f(int lim);
  endclass
  function void c::f(int lim);
    int r[$];
    r = super.m_v.find(x) with (x == lim + super.m_k);
    r = this.m_v.find_index with (item > m_k);
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      c x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  initial w = new();
endmodule
