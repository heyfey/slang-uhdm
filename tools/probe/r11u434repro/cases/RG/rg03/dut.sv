// § bareTdCopyOwnRangeAfterSpec434
package p;
  typedef logic [9:0] bs_t;
  class res #(type T = int);
    T v;
  endclass
endpackage
import p::*;
class C;
  function void f();
    res#(bs_t) r;
  endfunction
  function void g();
    res#(bs_t) r2;
  endfunction
endclass
module top;
endmodule
