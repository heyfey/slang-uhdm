// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
    int m_i[int];
    bit m_q[$];
    string m_s[string];
    bit [7:0] m_v[4];
    extern function void f(output bit r[c]);
  endclass
  function void c::f(output bit r[c]);
    bit [7:0] w;
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = 0;
    foreach (r[x])
      foreach (x.m_i[k])
        w[k] = 1;
    foreach (r[x])
      foreach (x.m_q[k])
        w[k +: 2] = 2'b01;
    foreach (r[x])
      foreach (x.m_s[k])
        w = k.len();
    foreach (r[x])
      foreach (x.m_v[k])
        w[k*2 -: 2] = {2{1'b1}};
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
  c z;
  u w;
  initial w = new();
endmodule
