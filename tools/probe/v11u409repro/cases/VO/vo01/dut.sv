// § oobEventTrigHoistNet409
package p;
  class b;
    event e;
  endclass
  class c extends b;
    extern function void f();
  endclass
  function void c::f();
    -> e;
  endfunction
endpackage
module top;
  import p::*;
endmodule
