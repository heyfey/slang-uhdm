// § cloneTfItemLocalOwnVar253 (an out-of-block class task with body io declarations)
package p;
  class c;
    extern task run(input int a);
  endclass
  task c::run;
    input int a;
    int x;
    int y;
    x = a;
    y = x;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
