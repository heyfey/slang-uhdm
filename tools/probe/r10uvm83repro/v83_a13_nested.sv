// v83 arm 13 — NESTED class: three-segment spelling Outer::Inner::td and the
// two-segment spelling on a nested owner.
package pa13;
  class zelem13; int q; endclass
  typedef zelem13 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zouter13;
    class zinner13;
      typedef zelem13 c_t;
    endclass
    typedef zelem13 out_t;
  endclass
  class aderiv13;
    extern function void f_oob();
    function void f_inline();
      zouter13::zinner13::c_t i_nested;
      zouter13::out_t         i_outer;
    endfunction
  endclass
  function void aderiv13::f_oob();
    zouter13::zinner13::c_t o_nested;
    zouter13::out_t         o_outer;
  endfunction
endpackage
module top13;
  initial begin
    pa13::aderiv13 u = new();
    u.f_oob();
  end
endmodule
