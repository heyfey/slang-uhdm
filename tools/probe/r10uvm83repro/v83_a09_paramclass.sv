// v83 arm 09 — PARAMETERIZED class as the typedef Owner, in and out of body.
package pa9;
  class zelem9; int q; endclass
  typedef zelem9 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase9 #(type T = int);
    typedef zelem9 c_t;
    typedef T      t_t;
  endclass
  class aderiv9 extends zbase9#(int);
    extern function void f_oob();
    function void f_inline();
      zbase9#(int)::c_t i_pscoped;
      c_t               i_inh;
    endfunction
  endclass
  function void aderiv9::f_oob();
    zbase9#(int)::c_t o_pscoped;
    c_t               o_inh;
  endfunction
endpackage
module top9;
  initial begin
    pa9::aderiv9 u = new();
    u.f_oob();
  end
endmodule
