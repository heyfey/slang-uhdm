// § oobInheritedCallBindsOwnPkgClone455
// two imported packages in q, calls homed in each; class extends a class of p2
package p1;
  function int f1(int a); return a + 1; endfunction
endpackage
package p2;
  function int f2(int a); return a + 2; endfunction
  class B;
    int w;
    function int f1(int a); return a; endfunction
  endclass
endpackage
package q;
  import p1::*;
  import p2::*;
  class C extends B;
    extern function int g();
  endclass
  function int C::g(); return f1(w) + f2(w); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule
