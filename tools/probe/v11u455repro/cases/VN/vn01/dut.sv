// § oobInheritedCallBindsOwnPkgClone455
// OOB constructor calling an imported free function
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function new();
  endclass
  function C::new(); v = f(3); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.v); end
endmodule
