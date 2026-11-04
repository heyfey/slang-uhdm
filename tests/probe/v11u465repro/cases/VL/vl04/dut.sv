// § cloneLvSharesHomeUnitTs465
// a package function over a package int array (not a class)
package h;
  int pa[5];
  function void g();
    foreach (pa[n]) pa[n] = n;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
