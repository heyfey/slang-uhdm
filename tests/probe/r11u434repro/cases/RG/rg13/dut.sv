// § bareTdCopyOwnRangeAfterSpec434
`define MX 10
package p;
  typedef logic signed [`MX-1:0] bs_t;
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
