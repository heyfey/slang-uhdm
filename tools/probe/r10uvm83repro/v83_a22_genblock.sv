// v83 arm 22 — the declaration inside a GENERATE block's initial, and inside a
// for/while body of an out-of-body method.
package pa22;
  class zelem22; int q; endclass
  typedef zelem22 pkg_c_t;
  class zbase22;
    typedef zelem22 c_t;
  endclass
  class aderiv22 extends zbase22;
    extern function void f_oob();
    function void f_inline();
      for (int i = 0; i < 2; i++) begin
        zbase22::c_t i_loop;
      end
    endfunction
  endclass
  function void aderiv22::f_oob();
    for (int i = 0; i < 2; i++) begin
      zbase22::c_t o_loop;
    end
    while (1) begin
      zbase22::c_t o_while;
      break;
    end
  endfunction
endpackage
module top22;
  for (genvar g = 0; g < 2; g++) begin : gb
    initial begin
      pa22::aderiv22 u = new();
      u.f_oob();
    end
  end
endmodule
