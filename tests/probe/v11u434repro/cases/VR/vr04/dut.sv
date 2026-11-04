// § bareTdCopyOwnRangeAfterSpec434
package p;
  typedef logic [7:0] bs_t;
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
class el; bs_t _val [2]; bs_t q[$]; endclass
module top; endmodule
