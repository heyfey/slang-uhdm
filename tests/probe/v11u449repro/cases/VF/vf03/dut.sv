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
package r;
  import p::*;
  int k;
endpackage
package s;
  import r::*;
  import p::*;
  int k2;
endpackage
module top;
  import s::*;
endmodule
