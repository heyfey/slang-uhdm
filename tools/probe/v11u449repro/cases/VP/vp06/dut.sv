// § pkgVarArrCloneLoopVarTs449
package o;
  int a[$];
endpackage
package p;
  import o::*;
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
