// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    bit x;
    extern function void f();
    extern function void g();
  endclass
  function void c::f();
    -> e;
  endfunction
  function void c::g();
    x = 1;
    -> e;
  endfunction
endpackage
module top;
  import p::*;
endmodule
