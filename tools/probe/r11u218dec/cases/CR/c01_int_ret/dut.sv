// § importCloneSharesHomeReturn218 — c01_int_ret: an out-of-block int method of a class in p1, cloned into the importer p2
package p1;
  class c;
    extern function int f();
  endclass
  function int c::f();
    return 7;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
