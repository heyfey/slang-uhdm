// § cloneRandWithParentCall252
package p;
  class item; rand int x; endclass
  class lib;
    extern virtual function bit execute(item w);
  endclass
  function bit lib::execute(item w);
    item it;
    it = w;
    return it.randomize() with {x > 2;};
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
