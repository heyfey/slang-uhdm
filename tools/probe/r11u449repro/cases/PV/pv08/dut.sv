// § pkgVarArrCloneLoopVarTs449
package p;
  logic [7:0] q [$];
  function void f();
    foreach (q[i]) q[i] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
