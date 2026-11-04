// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v); return 3; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
  function int wrap(int v); return rep(v); endfunction
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
