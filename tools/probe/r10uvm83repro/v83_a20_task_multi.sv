// v83 arm 20 — out-of-body TASK, several locals, a nested named begin, and an
// out-of-body method whose owner class is in a DIFFERENT package than the
// declaring class's own typedef owner (foreign shared typespec).
package pz20;
  class zelem20; int q; endclass
  typedef zelem20 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zfar20;
    typedef zelem20 far_t;
  endclass
endpackage
package pa20;
  import pz20::*;
  class zbase20;
    typedef int b_t;
  endclass
  class aderiv20 extends zbase20;
    extern task t_oob();
    function void f_inline();
      zbase20::b_t i_b;
      zfar20::far_t i_far;
    endfunction
  endclass
  task aderiv20::t_oob();
    zbase20::b_t o_b;
    zfar20::far_t o_far;
    begin : inner
      zbase20::b_t n_b;
      zfar20::far_t n_far;
    end
  endtask
endpackage
module top20;
  initial begin
    pa20::aderiv20 u = new();
    u.t_oob();
  end
endmodule
