// § cloneDotLoopVarBaseNoDrill248
// two levels: the int fallback object is itself the base of a third foreach
package p;
  class c;
    bit m_pred[c];
    extern function void f(inout bit r[c]);
  endclass
  function void c::f(inout bit r[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        foreach (nx.m_pred[ny])
          r[ny] = 1;
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
