// § cloneRandWithParentCall252
package p;
  class item; rand int x; endclass
  function automatic bit go(item it);
    return it.randomize() with { x == 5; };
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
