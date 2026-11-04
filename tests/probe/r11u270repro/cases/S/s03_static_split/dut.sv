// § scopedCallPrefixEndsAtColons270
package p;
  class util;
    static function int twice(int x);
      return 2 * x;
    endfunction
  endclass
  class user;
    int r;
    function void mk(int a);
      r = util::
        twice(a);
      r = util::twice(a);
    endfunction
  endclass
endpackage
module top;
  int q;
  initial q = p::util::
     twice(3);
endmodule
