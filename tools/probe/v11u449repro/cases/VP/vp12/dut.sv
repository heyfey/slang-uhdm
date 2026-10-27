// § pkgVarScopedNameInt449v
package p;
  int a[string];
  function automatic void f();
    foreach (p::a[x]) a[x] = 1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
