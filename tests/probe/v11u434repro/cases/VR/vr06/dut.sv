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
module top; bs_t w; logic [7:0] z; assign z = w; endmodule
