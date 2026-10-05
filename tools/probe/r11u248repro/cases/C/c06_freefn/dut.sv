// § cloneDotLoopVarBaseNoDrill248
// a package free function (not a class method) imported by another package and a module
package p;
  class c;
    bit m_pred[c];
  endclass
  function automatic void f(output bit r[c]);
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = 0;
  endfunction
endpackage
package q;
  import p::*;
  function automatic void g();
    bit t[c];
    f(t);
  endfunction
endpackage
module top;
  import p::*;
  import q::*;
  initial g();
endmodule
