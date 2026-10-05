// § cloneDotLoopVarBaseNoDrill248
// control: no importer copy (one package, the module only instantiates)
package p;
  class c;
    bit m_pred[c];
    extern function void f(output bit r[c]);
  endclass
  function void c::f(output bit r[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = 0;
  endfunction
endpackage
module top;
  import p::*;
  c z;
  initial z = new();
endmodule
