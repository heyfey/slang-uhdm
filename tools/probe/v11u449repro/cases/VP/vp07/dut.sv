// § pkgVarArrCloneLoopVarTs449
package p;
  logic [7:0] v;
  function void f();
    foreach (v[i]) v[i] = 1'b0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
