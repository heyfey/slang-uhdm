// § importCloneSharesHomeReturn218 — c04_two_importers: two importing packages
package p1;
  class c;
    extern function int f();
  endclass
  function int c::f();
    return 7;
  endfunction
endpackage
package p3;
  import p1::*;
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
