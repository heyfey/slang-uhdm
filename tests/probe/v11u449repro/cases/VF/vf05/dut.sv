// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    static function R get(); return null; endfunction
  endclass
  function void init();
    R top;
    top = R::get();
  endfunction
endpackage
package r;
  import p::*;
  class R;
    static function R get(); return null; endfunction
  endclass
  int k;
endpackage
module top;
  import r::*;
endmodule
