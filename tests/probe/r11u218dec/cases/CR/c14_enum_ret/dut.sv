// § importCloneSharesHomeReturn218 — c14_enum_ret: an enum-typedef return
package p1;
  typedef enum { A, B } e_t;
  class c;
    extern function e_t f();
  endclass
  function e_t c::f();
    return B;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
