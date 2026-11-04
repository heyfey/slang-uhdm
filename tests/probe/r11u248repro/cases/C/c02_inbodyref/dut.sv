// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
    function void f(ref int r[c], input string s[c]);
      foreach (r[x])
        foreach (x.m_pred[nx])
          r[nx] = 0;
      foreach (s[y])
        foreach (y.m_pred[ny])
          s[ny] = "a";
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
