// § importCloneSharesHomeReturn218 — c03_class_ret: a class-typed return
package p1;
  class c;
    extern function c f();
  endclass
  function c c::f();
    return this;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
