// § cloneLvSharesHomeUnitTs465
// a dynamic-array class property read through this. in an out-of-body method, two importers
package h;
  class C;
    string d[];
    extern function void f();
  endclass
  function void C::f();
    foreach (this.d[j]) d[j] = "";
  endfunction
endpackage
package a;
  import h::*;
endpackage
package b;
  import a::*;
  import h::*;
endpackage
import b::*;
module top;
endmodule
