// § oobInheritedCallBindsOwnPkgClone455
// $unit class (control) and package class, both OOB, both call f
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
import p::*;
class U;
  extern function int h();
endclass
function int U::h(); return f(4); endfunction
module top;
  import q::*;
  C c; U u;
  initial begin c = new; u = new; $display(c.g(), u.h()); end
endmodule
