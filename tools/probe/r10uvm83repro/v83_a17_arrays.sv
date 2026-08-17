// v83 arm 17 — DECLARATOR-ARRAY spellings of Owner::td inside an out-of-body
// method (the residue the pass names): fixed unpacked, queue, dynamic,
// associative — each with its in-body twin.
package pa17;
  class zelem17; int q; endclass
  typedef zelem17 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase17;
    typedef zelem17 c_t;
  endclass
  class aderiv17 extends zbase17;
    extern function void f_oob();
    function void f_inline();
      zbase17::c_t i_fix[4];
      zbase17::c_t i_q[$];
      zbase17::c_t i_dyn[];
      zbase17::c_t i_as[string];
    endfunction
  endclass
  function void aderiv17::f_oob();
    zbase17::c_t o_fix[4];
    zbase17::c_t o_q[$];
    zbase17::c_t o_dyn[];
    zbase17::c_t o_as[string];
  endfunction
endpackage
module top17;
  initial begin
    pa17::aderiv17 u = new();
    u.f_oob();
  end
endmodule
