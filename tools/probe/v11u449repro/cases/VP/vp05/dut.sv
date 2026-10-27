// § pkgVarArrCloneLoopVarTs449
package p;
  typedef struct { int x; } s_t;
  s_t a[];
  function void f();
    foreach (a[i]) a[i].x = i;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
