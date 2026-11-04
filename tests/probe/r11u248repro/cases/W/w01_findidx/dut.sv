// § cloneWithOperandChainName248
package p;
  class c;
    c m_sync[$];
    int m_v[$];
    int m_k;
    extern function void f(c a, c b);
  endclass
  function void c::f(c a, c b);
    int fi[$], fj[$], fk[$];
    int lim;
    fi = a.m_sync.find_index(node) with (node == b);
    fj = m_v.find(it) with (it > lim + m_k);
    fk = a.m_v.find_index with (item == lim);
    fk = a.m_v.find_first(x) with (x[1:0] == lim[1:0] && x > (lim >> 2));
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
