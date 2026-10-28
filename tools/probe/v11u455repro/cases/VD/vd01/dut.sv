// § oobInheritedCallBindsOwnPkgClone455
// imported function as a default argument of an OOB method
package p;
  function int f(int a); return a + 7; endfunction
endpackage
package q;
  import p::*;
  class C;
    extern function int g(int x = f(1));
  endclass
  function int C::g(int x = f(1)); return x; endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule
