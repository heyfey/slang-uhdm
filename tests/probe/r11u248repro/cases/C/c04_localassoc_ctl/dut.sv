// § cloneDotLoopVarBaseNoDrill248
// control: a subroutine-local and a property associative array (class index)
package p;
  class c;
    bit m_pred[c];
    bit m_own[c];
    function void f();
      bit l[c];
      foreach (l[x])
        foreach (x.m_pred[nx])
          l[nx] = 0;
      foreach (m_own[y])
        foreach (y.m_pred[ny])
          l[ny] = 1;
    endfunction
  endclass
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
