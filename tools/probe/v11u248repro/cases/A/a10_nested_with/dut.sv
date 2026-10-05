// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
    int m_v[$];
    extern function void f(output bit r[c]);
  endclass
  function void c::f(output bit r[c]);
    int q[$];
    foreach (r[x])
      foreach (x.m_pred[nx])
        q = m_v.find(z) with (z == nx.m_v.size());
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
