// § oobInheritedCallBindsOwnPkgClone455
package p;
  function int f(int a); $display(a); return a; endfunction
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
package q;
  import p::*;
  function int k(); return 3; endfunction
endpackage
package r;
  import q::*;
  import p::*;
  class C extends B;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v) + k(); endfunction
endpackage
module top;
  import r::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule
