// § pkgVarArrCloneLoopVarTs449
package p;
  int a[string];
  function void f();
    foreach (a[kk]) a[kk] = 1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
