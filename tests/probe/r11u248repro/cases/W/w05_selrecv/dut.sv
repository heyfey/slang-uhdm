// § cloneWithOperandChainName248
package p;
  function automatic int g(int v);
    return v + 1;
  endfunction
  class c;
    c m_sync[$];
    int m_v[$];
    bit [7:0] m_b[$];
    int m_k;
    function int get();
      return m_k;
    endfunction
    extern function void f(c a);
  endclass
  function void c::f(c a);
    int fi[$];
    int lim;
    fi = a.m_sync[0].m_v.find(x) with (x > lim + 4);
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g2();
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
