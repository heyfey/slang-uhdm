// v83 arm 24 — the FORMAL spelling of the same catch-all inside an OUT-OF-BODY
// method (the residue § classScopedTdFormalUnsupported34 the pass leaves
// uninstanced and says no corpus row can distinguish).  Also the RETURN type.
package pa24;
  class zelem24; int q; endclass
  typedef zelem24 pkg_c_t;
  class zbase24;
    typedef zelem24 c_t;
  endclass
  class aderiv24 extends zbase24;
    extern function zbase24::c_t f_oob(zbase24::c_t a_scoped, output zbase24::c_t b_scoped);
    function void f_inline(zbase24::c_t i_arg);
      zbase24::c_t i_loc;
    endfunction
  endclass
  function zbase24::c_t aderiv24::f_oob(zbase24::c_t a_scoped, output zbase24::c_t b_scoped);
    zbase24::c_t o_loc;
    return o_loc;
  endfunction
endpackage
module top24;
  initial begin
    pa24::aderiv24 u = new();
  end
endmodule
