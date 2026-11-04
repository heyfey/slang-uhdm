// § cloneRandWithParentCall252
package p;
  class item; rand int x; rand int y; endclass
  class lib;
    rand int z;
    extern virtual task execute(item w);
  endclass
  task lib::execute(item w);
    item it;
    it = w;
    if (!it.randomize()) $display("x");
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
