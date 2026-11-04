// § bareTdCopyOwnRangeAfterSpec434
package p;
  typedef bit [11:0] bs_t;
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
class el; bs_t _val; endclass
module top; endmodule
