// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
    byte m_b[4];
    extern function void f(ref string r[c]);
  endclass
  function void c::f(ref string r[c]);
    bit [15:0] w;
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = "z";
    foreach (r[x])
      foreach (x.m_b[k])
        w[k*4 +: 4] = {4{1'b1}};
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
