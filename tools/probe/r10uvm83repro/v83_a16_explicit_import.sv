// v83 arm 16 — EXPLICIT import of the owner class, out-of-body method in the
// importing package.
package pa16;
  class zelem16; int q; endclass
  typedef zelem16 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase16;
    typedef zelem16 c_t;
  endclass
endpackage
package pb16;
  import pa16::zbase16;
  class aderiv16 extends zbase16;
    extern function void f_oob();
    function void f_inline();
      zbase16::c_t i_scoped;
    endfunction
  endclass
  function void aderiv16::f_oob();
    zbase16::c_t o_scoped;
  endfunction
endpackage
module top16;
  initial begin
    pb16::aderiv16 u = new();
    u.f_oob();
  end
endmodule
