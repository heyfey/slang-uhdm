// § cloneRetVarViaRefKeepsHome462
package p;
  typedef logic [3:0] a_t;
  class C;
    extern function a_t f(int h);
  endclass
  function a_t C::f(int h);
    if (h > 0) f = h;
    else f = 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
  import p::*;
  C c;
endmodule
