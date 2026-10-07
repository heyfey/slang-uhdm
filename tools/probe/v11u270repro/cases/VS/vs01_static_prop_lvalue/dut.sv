// § scopedCallPrefixEndsAtColons270
package p;
  class c;
    static int cnt;
    static int arr[4];
    static function int get(); return cnt; endfunction
    localparam int LP = 3;
  endclass
  class u;
    int r;
    function void f();
      c:: cnt = 1;
      c::
        cnt++;
      r = c:: arr[1] + c:: LP;
      r = c::  get();
      r = c::/*x*/get();
    endfunction
  endclass
endpackage
module top;
  import p::*;
  u x;
endmodule
