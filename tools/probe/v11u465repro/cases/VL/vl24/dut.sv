// § cloneLvSharesHomeUnitTs465
// a package associative array of class handles indexed by string
package h;
  class W;
    int v;
  endclass
  W pm[string];
  function void g();
    foreach (pm[s]) pm[s].v = 1;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
