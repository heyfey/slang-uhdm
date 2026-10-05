// § cloneDotLoopVarBaseNoDrill248
// control: a class-typed element makes the home object a class_var, the walk resolves
package p;
  class c;
    bit m_pred[c];
    extern function void f(output c r[c]);
  endclass
  function void c::f(output c r[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = null;
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
