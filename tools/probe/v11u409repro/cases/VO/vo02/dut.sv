// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    extern function void f();
  endclass
  function void c::f();
    -> this.e;
  endfunction
endpackage
module top;
  import p::*;
endmodule
