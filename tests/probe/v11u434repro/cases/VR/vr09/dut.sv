// § bareTdCopyOwnRangeAfterSpec434
package p;
  typedef logic [7:0] bs_t; typedef bs_t bs2_t;
  class res #(type T = int);
    T v;
  endclass
endpackage
import p::*;
class C;
  function void f();
    res#(bs_t) r;
  endfunction
endclass
class el; bs2_t _val; endclass
module top; endmodule
