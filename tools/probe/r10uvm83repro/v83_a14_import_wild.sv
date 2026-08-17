// v83 arm 14 — WILDCARD IMPORT: pb14 imports pa14::*, and pb14's class has an
// out-of-body method declaring pa14's class-scoped typedef.  This is the
// package-clone / importCopyTsInst territory the pass calls unexercised.
package pa14;
  class zelem14; int q; endclass
  typedef zelem14 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase14;
    typedef zelem14 c_t;
  endclass
endpackage
package pb14;
  import pa14::*;
  class aderiv14 extends zbase14;
    extern function void f_oob();
    function void f_inline();
      zbase14::c_t i_scoped;
    endfunction
  endclass
  function void aderiv14::f_oob();
    zbase14::c_t o_scoped;
  endfunction
endpackage
module top14;
  import pb14::*;
  initial begin
    aderiv14 u = new();
    u.f_oob();
  end
endmodule
