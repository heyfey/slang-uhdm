// § oobInheritedCallBindsOwnPkgClone455
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    function int h(); return f(1); endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.h()); end
endmodule
