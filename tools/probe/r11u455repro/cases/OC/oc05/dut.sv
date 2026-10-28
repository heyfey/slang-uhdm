// § oobInheritedCallBindsOwnPkgClone455
package p;
  function int f(int a); $display(a); return a; endfunction
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
import p::*;
class C extends B;
  extern function int g();
endclass
function int C::g(); return f(2); endfunction
module top;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule
