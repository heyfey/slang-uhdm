// § oobInheritedCallBindsOwnPkgClone455
// OOB static function
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    extern static function int g(int x);
  endclass
  function int C::g(int x); return f(x); endfunction
endpackage
module top;
  import q::*;
  initial $display(C::g(5));
endmodule
