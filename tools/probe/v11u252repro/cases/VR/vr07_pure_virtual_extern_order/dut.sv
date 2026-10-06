// § cloneRandWithParentCall252
package p;
  class item; rand int x; endclass
  virtual class abs;
    pure virtual function bit go(item it);
  endclass
  class impl extends abs;
    extern virtual function bit go(item it);
  endclass
  function bit impl::go(item it);
    return it.randomize() with { x == 5; };
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
