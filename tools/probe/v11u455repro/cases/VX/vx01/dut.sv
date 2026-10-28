// § oobInheritedCallBindsOwnPkgClone455
// re-export chain: q imports p::* and exports it; r imports q::*; class in r calls f
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  export p::*;
  function int dummy(); return f(0); endfunction
endpackage
package r;
  import q::*;
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
module top;
  import r::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule
