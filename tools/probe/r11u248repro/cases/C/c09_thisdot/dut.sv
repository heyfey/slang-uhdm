// § cloneDotLoopVarBaseNoDrill248
// this. receivers and a class specialisation, the base a formal assoc of bit
package p;
  class c #(int N = 2);
    bit m_pred[c#(N)];
    bit [N-1:0] m_w;
    extern function void f(output bit r[c#(N)]);
  endclass
  function void c::f(output bit r[c#(N)]);
    foreach (this.m_pred[k])
      r[k] = this.m_w[0];
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = m_w[N-1];
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      c #(4) x;
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
