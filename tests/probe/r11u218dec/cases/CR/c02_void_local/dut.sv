// § importCloneSharesHomeReturn218 — c02_void_local: a void out-of-block method with a local variable
package p1;
  class c;
    extern function void f();
  endclass
  function void c::f();
    int t;
    t = 3;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
