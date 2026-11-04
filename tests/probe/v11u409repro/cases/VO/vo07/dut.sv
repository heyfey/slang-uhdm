// § oobEventTrigHoistNet409
package p;
  class c;
    static event e;
    extern static function void f();
  endclass
  function void c::f();
    -> e;
  endfunction
endpackage
module top;
  import p::*;
endmodule
