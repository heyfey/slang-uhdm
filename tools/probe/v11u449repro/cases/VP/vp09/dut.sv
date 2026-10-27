// § pkgVarArrCloneLoopVarTs449
package p;
  int a[int];
  class D;
    function void g();
      foreach (a[kk]) a[kk] = 0;
    endfunction
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
