// v83 arm 19 — NEGATIVE CONTROL: `pkg::td` (a PACKAGE typedef), which is `::`
// but not a class scope, in and out of an out-of-body body; plus a body with no
// scoped typedef at all.
package pa19;
  class zelem19; int q; endclass
  typedef zelem19 pkg_c_t;
  typedef struct { int a; } pkg_s_t;
  class aderiv19;
    extern function void f_oob();
    function void f_inline();
      pa19::pkg_c_t i_p;
      pa19::pkg_s_t i_ps;
      pkg_c_t       i_bare;
      int           i_int;
    endfunction
  endclass
  function void aderiv19::f_oob();
    pa19::pkg_c_t o_p;
    pa19::pkg_s_t o_ps;
    pkg_c_t       o_bare;
    int           o_int;
  endfunction
endpackage
module top19;
  initial begin
    pa19::aderiv19 u = new();
    u.f_oob();
  end
endmodule
