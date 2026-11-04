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
    begin bit ok; ok = it.randomize() with {x < 4;}; end
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
