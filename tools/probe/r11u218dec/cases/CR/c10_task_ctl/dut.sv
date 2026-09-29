// § importCloneSharesHomeReturn218 — c10_task_ctl: control: an out-of-block task (no return variable)
package p1;
  class c;
    extern task t(int a);
  endclass
  task c::t(int a);
    int b;
    b = a;
  endtask
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
