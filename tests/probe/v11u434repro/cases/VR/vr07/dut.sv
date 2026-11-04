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
class el; function bs_t g(bs_t a); bs_t l; return a; endfunction endclass
module top; endmodule
