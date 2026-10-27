// § pkgVarArrCloneLoopVarTs449
package p;
  int q[3];
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
