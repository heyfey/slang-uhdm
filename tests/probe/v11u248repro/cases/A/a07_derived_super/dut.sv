// § cloneDotLoopVarBaseNoDrill248
package p;
  class b;
    bit m_pred[b];
  endclass
  class c extends b;
    extern function void f(output bit r[b]);
  endclass
  function void c::f(output bit r[b]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = super.m_pred.exists(nx);
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
