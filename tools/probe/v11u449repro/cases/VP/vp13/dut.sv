// § pkgVarScopedNameInt449v
package p;
  class C; endclass
  C q[$];
  class D;
    function void g();
      foreach (p::q[i]) q[i] = null;
    endfunction
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
