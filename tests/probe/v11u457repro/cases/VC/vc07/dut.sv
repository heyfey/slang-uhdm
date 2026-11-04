// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v); return v + 1; endfunction
  class C;
    extern function int f(int v);
  endclass
  function int C::f(int v);
    return rep(v);
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
