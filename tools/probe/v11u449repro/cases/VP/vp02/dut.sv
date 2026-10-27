// § pkgVarArrCloneLoopVarTs449
package p;
  int a[2][3];
  function void f();
    foreach (a[i,j]) a[i][j] = i + j;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
