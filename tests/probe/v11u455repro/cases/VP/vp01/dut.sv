// § oobInheritedCallBindsOwnPkgClone455
// parameterized class with OOB method
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C #(int N = 4);
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v + N); endfunction
endpackage
module top;
  import q::*;
  C #(8) c;
  initial begin c = new; $display(c.g()); end
endmodule
