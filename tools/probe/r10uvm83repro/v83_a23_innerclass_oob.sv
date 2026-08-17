// v83 arm 23 — an OUT-OF-BODY method of a class NESTED inside another class,
// and a package free TASK.
package pa23;
  class zelem23; int q; endclass
  typedef zelem23 pkg_c_t;
  class zbase23;
    typedef zelem23 c_t;
  endclass
  class aouter23;
    class ainner23 extends zbase23;
      extern function void f_oob();
      function void f_inline();
        zbase23::c_t i_scoped;
      endfunction
    endclass
    function void ainner23::f_oob();
      zbase23::c_t o_scoped;
    endfunction
  endclass
  task freetask23();
    zbase23::c_t t_scoped;
    begin
      zbase23::c_t t_blk;
    end
  endtask
endpackage
module top23;
  initial pa23::freetask23();
endmodule
