// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v); return v + 1; endfunction
  class C;
    int v;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
package q;
  import p::*;
  class D extends C;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
