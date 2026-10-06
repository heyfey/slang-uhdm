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
    begin item __seq; $cast(__seq, it); if ((__seq == null || 1) && !it.randomize() with {}) $display("e"); end
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
