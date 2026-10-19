// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    extern function void f();
  endclass
  function void c::f();
    -> e;
  endfunction
endpackage
import p::*;
module top;
endmodule
