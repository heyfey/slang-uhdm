// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
    bit [7:0] m_v[4];
    extern function void f(input logic [3:0] r[c], output logic [15:0] w);
  endclass
  function void c::f(input logic [3:0] r[c], output logic [15:0] w);
    foreach (r[x])
      foreach (x.m_v[k])
        w[k*4 +: 4] = r[x][k -: 1];
    foreach (r[x])
      foreach (x.m_v[k, j])
        w[k + j] = {2{1'b0}} == 2'b00;
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
