// v83 arm 04 — OUT-OF-BODY method with a BLOCK-ITEM local: the UVM shape
// (class_var parented at a synthetic begin).  SITE 2 with oobHomePkg.
package pa4;
  class zelem4; int q; endclass
  typedef zelem4 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase4;
    typedef zelem4 c_t;
  endclass
  class aderiv4 extends zbase4;
    extern function void f_oob();
    function void f_inline();
      begin
        zbase4::c_t i_blk;
      end
    endfunction
  endclass
  function void aderiv4::f_oob();
    begin
      zbase4::c_t o_blk;
    end
  endfunction
endpackage
module top4;
  initial begin
    pa4::aderiv4 u = new();
    u.f_oob();
  end
endmodule
