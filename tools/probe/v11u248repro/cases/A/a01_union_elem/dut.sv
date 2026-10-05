// § cloneDotLoopVarBaseNoDrill248
package p;
  typedef union packed { bit [3:0] m_pred; bit [3:0] o; } u_t;
  class c;
    bit m_pred[c];
    extern function void f(output u_t r[c]);
  endclass
  function void c::f(output u_t r[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = '0;
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
