// v83 arm 21 — class in an INTERFACE and in a PROGRAM, each with an
// out-of-body method: oobHomePkg requires a PACKAGE parent, so both must stay
// uninstanced.  Negative control for the stamp's gate.
interface class_holder21;
  class zelem21; int q; endclass
  typedef zelem21 pkg_c_t;
  class zbase21;
    typedef zelem21 c_t;
  endclass
  class aderiv21 extends zbase21;
    extern function void f_oob();
    function void f_inline();
      zbase21::c_t i_scoped;
    endfunction
  endclass
  function void aderiv21::f_oob();
    zbase21::c_t o_scoped;
  endfunction
endinterface
module top21;
  class_holder21 h();
endmodule
