// § cloneDotLoopVarBaseNoDrill248
package p;
  typedef enum bit [1:0] {A, B, C} e_t;
  class c;
    bit m_pred[c];
    int m_i[int];
    extern function void f(output e_t r[c]);
  endclass
  function void c::f(output e_t r[c]);
    int w;
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = B;
    foreach (r[x])
      foreach (x.m_i[k])
        w = k;
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
