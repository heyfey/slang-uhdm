// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    bit locked;
    extern function void f();
  endclass
  function void c::f();
    locked = 1;
    -> e;
  endfunction
endpackage
module top;
  import p::*;
endmodule
