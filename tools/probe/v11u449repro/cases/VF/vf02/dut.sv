// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    extern static task t(int x);
  endclass
  task R::t(int x);
  endtask
  task run();
    R::t(1);
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
