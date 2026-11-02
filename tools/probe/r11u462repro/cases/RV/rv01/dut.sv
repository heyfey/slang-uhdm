// § cloneRetVarViaRefKeepsHome462
package p;
  typedef bit [7:0] a_t;
  class C;
    extern virtual function a_t f(int h);
  endclass
  function a_t C::f(int h);
    f = h;
    f += 1;
  endfunction
endpackage
package q;
  import p::*;
  class D;
    C c;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
