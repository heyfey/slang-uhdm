// § scopedCallPrefixEndsAtColons270
package p;
  class c;
    static int k;
    static function int mk(int a); return a; endfunction
  endclass
endpackage
module top;
  import p::*;
  int r;
  initial begin
    r = c:: mk(1);
    r = c::
        k;
    c:: k = 2;
  end
  always_comb r = c:: mk(r);
endmodule
