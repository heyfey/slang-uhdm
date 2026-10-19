// § oobEventTrigHoistNet409
package p;
  class c;
    event e1, e2;
    int k;
    extern function void f();
  endclass
  function void c::f();
    -> e2;
    k = 1;
    -> e1;
    -> e2;
  endfunction
endpackage
import p::*;
module top;
endmodule
