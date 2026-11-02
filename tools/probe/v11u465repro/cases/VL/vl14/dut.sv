// § cloneLvSharesHomeUnitTs465
// a package function over a string queue formal
package h;
  function int g(string sq[$]);
    int s;
    foreach (sq[i]) s += sq[i].len();
    return s;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
