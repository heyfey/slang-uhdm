// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    extern static function R get();
  endclass
  function R R::get();
    return null;
  endfunction
  function void init();
    R top;
    top = R::get();
  endfunction
endpackage
package q;
  import p::*;
  int k;
endpackage
module top;
  import q::*;
endmodule
