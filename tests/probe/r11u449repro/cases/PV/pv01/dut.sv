// § pkgVarArrCloneLoopVarTs449
package p;
  class C; endclass
  C q[$];
  function void f();
    foreach (q[i]) q[i] = null;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
