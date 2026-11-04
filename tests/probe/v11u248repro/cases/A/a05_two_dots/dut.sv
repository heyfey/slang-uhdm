// § cloneDotLoopVarBaseNoDrill248
package p;
  class d;
    bit m_pred[d];
  endclass
  class c;
    d sub;
    extern function void f(output bit r[c], output bit t[d]);
  endclass
  function void c::f(output bit r[c], output bit t[d]);
    foreach (r[x])
      foreach (x.sub.m_pred[nx])
        t[nx] = 1;
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
