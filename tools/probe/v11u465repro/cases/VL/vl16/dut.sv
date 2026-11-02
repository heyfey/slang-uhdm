// § cloneLvSharesHomeUnitTs465
// a method-local fixed array in an out-of-body method
package h;
  class C;
    extern function int f();
  endclass
  function int C::f();
    int loc[3];
    int s;
    foreach (loc[i]) s += loc[i];
    return s;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
