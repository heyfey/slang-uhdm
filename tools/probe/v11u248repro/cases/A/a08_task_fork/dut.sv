// § cloneDotLoopVarBaseNoDrill248
package p;
  class c;
    bit m_pred[c];
    extern task t(output bit r[c]);
  endclass
  task c::t(output bit r[c]);
    fork
      foreach (r[x])
        foreach (x.m_pred[nx])
          r[nx] = 1;
    join
  endtask
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
