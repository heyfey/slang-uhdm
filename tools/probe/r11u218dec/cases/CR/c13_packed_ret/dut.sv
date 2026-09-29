// § importCloneSharesHomeReturn218 — c13_packed_ret: a packed-vector return
package p1;
  class c;
    extern function logic [7:0] f();
  endclass
  function logic [7:0] c::f();
    return 8'h5;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
