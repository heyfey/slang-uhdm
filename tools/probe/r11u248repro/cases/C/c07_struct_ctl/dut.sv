// § cloneDotLoopVarBaseNoDrill248
// control: a packed-struct element; the struct_var base drills
package p;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t;
  class c;
    bit m_pred[c];
    extern function void f(output s_t r[c], output bit o[c]);
  endclass
  function void c::f(output s_t r[c], output bit o[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        o[nx] = r[x].a[1];
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
