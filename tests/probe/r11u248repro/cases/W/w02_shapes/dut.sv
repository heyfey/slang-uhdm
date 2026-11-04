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
    fi = m_v.find_index(e) with (g(e) > lim);
    fi = m_sync.find_index(s) with (s.m_k == this.m_k);
    fi = m_sync.find_index(s) with (s.get() > lim ? 1 : 0);
    fi = m_b.find_index(b) with (b[3] == 1'b1 || b[7:4] == lim[3:0]);
    fi = a.m_sync.find_index(s) with (s.m_v.size() > 2);
    fi = m_v.find_index(e) with (e inside {1, lim});
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
