// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    extern function void f(event x);
  endclass
  function void c::f(event x);
    -> x;
  endfunction
endpackage
module top;
  import p::*;
endmodule
