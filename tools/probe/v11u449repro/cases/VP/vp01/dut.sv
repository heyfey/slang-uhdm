// § pkgVarArrCloneLoopVarTs449
package p;
  int a[4];
  function void f();
    foreach (a[i]) a[i] = i;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
