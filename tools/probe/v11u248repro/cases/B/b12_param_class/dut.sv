// § cloneWithOperandChainName248
package p;
  class c #(int W = 4);
    int m_v[$];
    c #(W) m_sync[$];
    extern function void f(int lim);
  endclass
  function void c::f(int lim);
    int r[$];
    r = m_v.find(x) with (x[W-1:0] == lim[W-1:0]);
    foreach (m_sync[i])
      r = m_sync[i].m_v.find_index with (item > m_sync[i].m_v.size());
  endfunction
  class k;
    c #(8) h;
  endclass
endpackage
package q;
  import p::*;
  class u;
    function void g();
      k x;
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
