// v83 arm 06 — class declared in a MODULE, out-of-body method inside the module.
// oobHomePkg is NULL (parent is not a package): the stamp must stay inert.
module top6;
  class zelem6; int q; endclass
  typedef zelem6 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase6;
    typedef zelem6 c_t;
  endclass
  class aderiv6 extends zbase6;
    extern function void f_oob();
    function void f_inline();
      zbase6::c_t i_scoped;
    endfunction
  endclass
  function void aderiv6::f_oob();
    zbase6::c_t o_scoped;
  endfunction
  function void modfn6();
    zbase6::c_t m_scoped;
  endfunction
  initial begin
    aderiv6 u = new();
    u.f_oob();
    modfn6();
  end
endmodule
