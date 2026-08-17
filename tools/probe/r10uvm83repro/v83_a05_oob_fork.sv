// v83 arm 05 — OUT-OF-BODY method, FORK arm local.
package pa5;
  class zelem5; int q; endclass
  typedef zelem5 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase5;
    typedef zelem5 c_t;
  endclass
  class aderiv5 extends zbase5;
    extern task t_oob();
    task t_inline();
      fork
        begin
          zbase5::c_t i_fk;
        end
      join_none
    endtask
  endclass
  task aderiv5::t_oob();
    fork
      begin
        zbase5::c_t o_fk;
      end
    join_none
  endtask
endpackage
module top5;
  initial begin
    pa5::aderiv5 u = new();
    u.t_oob();
  end
endmodule
