// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
  endclass
  class pc #(int N = 2);
    extern function void f(output bit [N-1:0] r[c]);
  endclass
  function void pc::f(output bit [N-1:0] r[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = '1;
  endfunction
  class k;
    pc #(4) h;
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
