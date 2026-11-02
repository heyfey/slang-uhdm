// § cloneLvSharesHomeUnitTs465
// a 2-D foreach over a class property int m[4][3] in an out-of-body method; $unit imports a, a imports h
package h;
  class C;
    int m[4][3];
    extern function void f();
  endclass
  function void C::f();
    foreach (m[i, j]) m[i][j] = i + j;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
