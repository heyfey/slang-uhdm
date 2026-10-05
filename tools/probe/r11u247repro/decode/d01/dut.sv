// § cloneLoopVarClassPropArrayTs238
package p;
  class c;
    bit m_pred[c];
    extern function void f(output bit r[c]);
  endclass
  function void c::f(output bit r[c]);
    c succ[$];
    foreach (succ[s])
      foreach (succ[s].m_pred[pred])
        r[pred] = 1;
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = 0;
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
  c z;
  u w;
  initial w = new();
endmodule
