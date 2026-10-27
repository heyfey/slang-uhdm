// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    static function int get();
      return 1;
    endfunction
  endclass
  function int init();
    return R::get();
  endfunction
endpackage
package q;
  import p::*;
  int k;
endpackage
module top;
  import q::*;
endmodule
