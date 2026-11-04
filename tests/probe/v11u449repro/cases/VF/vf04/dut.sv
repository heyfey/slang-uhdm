// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    extern static function R get();
  endclass
  function R R::get();
    return null;
  endfunction
  function R helper(); return null; endfunction
  function void init();
    R top;
    top = R::get();
    top = helper();
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
