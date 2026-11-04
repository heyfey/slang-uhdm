// § pkgVarArrCloneLoopVarTs449
package p;
  string q;
  function void f();
    foreach (q[i]) q[i] = "a";
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
