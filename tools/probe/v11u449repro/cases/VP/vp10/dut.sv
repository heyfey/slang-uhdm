// § pkgVarArrCloneLoopVarTs449
package p;
  int a[$];
  function void f();
    foreach (a[i]) a[i] = i;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
package s;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
  import s::*;
endmodule
