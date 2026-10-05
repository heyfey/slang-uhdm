// § cloneLoopVarClassPropStringTs248
package p;
  class b;
    string m_base;
  endclass
  class c extends b;
    string m_own;
    c m_peer;
    extern function int f();
  endclass
  function int c::f();
    int n;
    foreach (m_base[i]) n += m_base[i];
    foreach (m_peer.m_own[j]) n += j;
    foreach (super.m_base[k]) n += k;
    return n;
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
