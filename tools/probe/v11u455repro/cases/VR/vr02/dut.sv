// § oobInheritedCallBindsOwnPkgClone455
// imported function inside randomize() with {} of an OOB method, and in an OOB constraint
package p;
  function int f(int a); return a + 1; endfunction
endpackage
package q;
  import p::*;
  class C;
    rand int x;
    extern constraint c;
    extern function void g();
  endclass
  constraint C::c { x < f(10); }
  function void C::g(); void'(this.randomize() with { x > f(1); }); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; c.g(); end
endmodule
