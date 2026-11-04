// § cloneTfItemLocalOwnVar253 (a task with body io and a static local)
package p;
  task t;
    input int a;
    output int o;
    static int cnt = 0;
    cnt = cnt + a;
    o = cnt;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
