// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    extern static function int get();
  endclass
  function int R::get();
    return 1;
  endfunction
  function int init();
    return R::get();
  endfunction
endpackage
package q;
  import p::*;
  function int own();
    return R::get();
  endfunction
endpackage
module top;
  import q::*;
endmodule
