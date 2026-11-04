// § pkgVarArrCloneLoopVarTs449
package p;
  class C; endclass
  C q[$];
  class D;
    function void g();
      foreach (q[i]) q[i] = null;
    endfunction
  endclass
  function void f();
    foreach (q[j]) q[j] = null;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
