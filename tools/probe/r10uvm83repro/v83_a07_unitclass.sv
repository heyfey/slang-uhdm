// v83 arm 07 — class at $unit scope with an out-of-body method at $unit.
class zelem7; int q; endclass
  typedef zelem7 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
class zbase7;
  typedef zelem7 c_t;
endclass
class aderiv7 extends zbase7;
  extern function void f_oob();
  function void f_inline();
    zbase7::c_t i_scoped;
  endfunction
endclass
function void aderiv7::f_oob();
  zbase7::c_t o_scoped;
endfunction
function void unitfn7();
  zbase7::c_t u_scoped;
endfunction
module top7;
  initial begin
    aderiv7 u = new();
    u.f_oob();
    unitfn7();
  end
endmodule
