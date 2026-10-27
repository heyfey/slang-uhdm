// § pkgVarScopedNameInt449v
package p;
  int a[$];
  function void f();
    foreach (p::a[i]) a[i] = i;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
