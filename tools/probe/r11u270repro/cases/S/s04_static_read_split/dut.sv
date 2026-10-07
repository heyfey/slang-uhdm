// § scopedCallPrefixEndsAtColons270
package p;
  class util;
    static int K = 3;
    localparam int L = 4;
  endclass
  class user;
    int r;
    function void mk();
      r = util::
        K;
      r = util:: L + util::K;
    endfunction
  endclass
endpackage
module top;
endmodule
