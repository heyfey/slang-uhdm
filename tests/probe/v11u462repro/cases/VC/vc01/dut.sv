// § cloneRetVarViaRefKeepsHome462
package p;
  typedef bit [7:0] a_t;
  class M;
    function a_t sub(); return 3; endfunction
  endclass
  class C;
    M m;
    extern function a_t f();
  endclass
  function a_t C::f();
    f = m.sub();
  endfunction
endpackage
package q;
  import p::*;
  class D extends C;
  endclass
endpackage
module top;
  import q::*;
  import p::*;
  D d;
endmodule
