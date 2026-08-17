// v83 arm 11 — FORWARD typedef of a class, and a forward-declared class used as
// the typedef target, inside and outside a body.
package pa11;
  typedef class zfwd11;
  class zbase11;
    typedef zfwd11 c_t;
  endclass
  class zfwd11; int q; endclass
  typedef zfwd11 pkg_c_t;   // the COMPETING claim
  class aderiv11 extends zbase11;
    extern function void f_oob();
    function void f_inline();
      zbase11::c_t i_fwd;
    endfunction
  endclass
  function void aderiv11::f_oob();
    zbase11::c_t o_fwd;
  endfunction
endpackage
module top11;
  initial begin
    pa11::aderiv11 u = new();
    u.f_oob();
  end
endmodule
