// § cloneTfItemLocalOwnVar253 (control: a paren-less out-of-block class task without io)
package p;
  class c;
    int m;
    extern task t();
  endclass
  task c::t;
    int x;
    x = m;
    m = x;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
