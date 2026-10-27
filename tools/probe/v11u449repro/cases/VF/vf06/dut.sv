// § freeCloneCmCallKeepsClassMethod449
package p;
  class R;
    static function int cnt(); return 1; endfunction
  endclass
  function automatic int init();
    int t;
    t = R::cnt() + R::cnt();
    return t;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
  initial $display(p::init());
endmodule
