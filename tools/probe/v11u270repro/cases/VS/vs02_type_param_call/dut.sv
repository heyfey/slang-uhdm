// § scopedCallPrefixEndsAtColons270
package p;
  class f;
    static function int make(); return 1; endfunction
    static int k;
  endclass
  class g #(type T = f);
    int r;
    function void h();
      r = T:: make();
      r = T::
          make();
      r = T:: k;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  g #(f) x;
endmodule
