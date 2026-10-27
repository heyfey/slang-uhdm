// § freeCloneCmCallKeepsClassMethod449
package o;
  class R;
    static function R get(); return null; endfunction
  endclass
endpackage
package p;
  import o::*;
  function void init();
    R top;
    top = R::get();
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
