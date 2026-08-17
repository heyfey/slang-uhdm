// v83 arm 15 — RE-EXPORT: pb15 imports and EXPORTS pa15::*, pc15 imports pb15::*
// and its class's out-of-body method declares the re-exported class's typedef.
package pa15;
  class zelem15; int q; endclass
  typedef zelem15 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase15;
    typedef zelem15 c_t;
  endclass
endpackage
package pb15;
  import pa15::*;
  export pa15::*;
endpackage
package pc15;
  import pb15::*;
  class aderiv15 extends zbase15;
    extern function void f_oob();
    function void f_inline();
      zbase15::c_t i_scoped;
    endfunction
  endclass
  function void aderiv15::f_oob();
    zbase15::c_t o_scoped;
  endfunction
endpackage
module top15;
  import pc15::*;
  initial begin
    aderiv15 u = new();
    u.f_oob();
  end
endmodule
